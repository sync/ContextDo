#import "TasksMapViewController.h"
#import "UICRouteAnnotation.h"
#import "UICRouteOverlay.h"
#import "TaskAnnotation.h"
#import "TaskContainerViewController.h"

@interface TasksMapViewController (private)

- (void)showCurrentLocation;
- (void)updateDirections;
- (void)refreshTasks;

@end

@implementation TasksMapViewController

@synthesize mapView, tasks, directions, customSearchBar, group, mainNavController;
@synthesize routeLine, routeLineView;

#pragma mark -
#pragma mark Setup

- (NSString *)stringForLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude
{
	return [NSString stringWithFormat:@"%f,%f", latitude, longitude];
}

- (BOOL)isTodayTasks
{
	return [self.group.name isEqualToString:TodaysTasksPlacholder];
}

- (BOOL)isNearTasks
{
	return [self.group.name isEqualToString:NearTasksPlacholder];
}

- (NSString *)nowDue
{
	NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	// 2010-07-24
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];
	return [dateFormatter stringFromDate:[NSDate date]];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	[self.customSearchBar setBackgroundImage:[DefaultStyleSheet sharedDefaultStyleSheet].navBarBackgroundImage
								 forBarStyle:UIBarStyleBlackOpaque];
	
	self.mapView.showsUserLocation = TRUE;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTasks) name:TaskDeleteNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTasks) name:TaskEditNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTasks) name:TaskAddNotification object:nil];
	
	if (self.isTodayTasks) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:TasksDueTodayDidLoadNotification object:nil];
		[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:TasksDueTodayDidLoadNotification];
	} else if (self.isNearTasks) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:TasksWithinDidLoadNotification object:nil];
		[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:TasksWithinDidLoadNotification];
	} else {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:TasksDidLoadNotification object:nil];
		[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:TasksDidLoadNotification];
	}
	[self refreshTasks];
}

#pragma mark -
#pragma mark Actions

- (void)refreshTasks
{
	if (self.isTodayTasks) {
		[[APIServices sharedAPIServices]refreshTasksDueToday];
	} else if (self.isNearTasks) {
		CLLocationCoordinate2D coordinate = [AppDelegate sharedAppDelegate].currentLocation.coordinate;
		[[APIServices sharedAPIServices]refreshTasksWithLatitude:coordinate.latitude longitude:coordinate.longitude inBackground:FALSE]; // TODO within user's pref
	} else {
		[[APIServices sharedAPIServices]refreshTasksWithGroupId:self.group.groupId];
	}
}

#pragma mark -
#pragma mark Content reloading

- (void)shouldReloadContent:(NSNotification *)notification
{
	NSDictionary *dict = [notification object];
	
	NSArray *newTasks = [dict valueForKey:@"tasks"];
	
	NSMutableArray *tasksToAdd = [NSMutableArray arrayWithArray:newTasks];
	if (self.mapView.userLocation) {
		CLLocation *startLocation = nil;
		if (TARGET_IPHONE_SIMULATOR) {
			startLocation = [AppDelegate sharedAppDelegate].currentLocation;
		} else {
			startLocation = self.mapView.userLocation.location;
		}
		Task *currentLocation = [Task taskWithId:[NSNumber numberWithInteger:NSNotFound]
											name:CURRENT_LOCATION_PLACEHOLDER
										latitude:startLocation.coordinate.latitude
									   longitude:startLocation.coordinate.longitude];
		[tasksToAdd insertObject:currentLocation atIndex:0];
	}
	
	self.tasks = [NSArray arrayWithArray:tasksToAdd];;
	
	[self refreshTasksDirection];
}

- (void)refreshTasksDirection
{
	[self performSelectorOnMainThread:@selector(baseLoadingViewCenterDidStartForKey:) withObject:@"direction" waitUntilDone:FALSE];
	
	for (id<MKAnnotation> annotation in self.mapView.annotations) {
		if ([annotation isKindOfClass:[UICRouteAnnotation class]]) {
			[self.mapView removeAnnotation:annotation];
		}
	}
	self.routeLineView = nil;
	self.directions = [UICGDirections sharedDirections];
	self.directions.delegate = self;
	
	UICGDirectionsOptions *options = [[[UICGDirectionsOptions alloc] init] autorelease];
	options.travelMode = UICGTravelModeDriving;
	
	[self updateDirections];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	
	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:FALSE];
	self.mapView = nil;
	
	self.customSearchBar = nil;
}

- (void)updateDirections
{
	UICGDirectionsOptions *options = [[[UICGDirectionsOptions alloc] init] autorelease];
	options.travelMode = UICGTravelModeDriving;
	[self.directions loadFromWaypoints:[self.tasks valueForKey:@"latLngString"] options:options];
}

#pragma mark -
#pragma mark UICGDirectionsDelegate

- (void)directionsDidUpdateDirections:(UICGDirections *)aDirections {
	[self performSelectorOnMainThread:@selector(baseLoadingViewCenterDidStopForKey:) withObject:@"direction" waitUntilDone:FALSE];
	
	// Overlay polylines
	UICGPolyline *polyline = [[aDirections routeAtIndex:0] overviewPolyline];
	NSArray *routePoints = [polyline points];
	
	UICRouteOverlay *overlay = [UICRouteOverlay routeOverlayWithPoints:routePoints];
	self.routeLine = overlay.polyline;
	[self.mapView addOverlay:self.routeLine];
	[self.mapView setVisibleMapRect:overlay.mapRect];
	
	// here we can have multiple routes todo
	NSInteger numberOfRoutes = [self.directions numberOfRoutes];
	if (numberOfRoutes > 0) {
		UICGRoute *route = [self.directions routeAtIndex:0];
		
		NSArray *waypointOrder = route.waypointOrder;
		NSMutableArray *organizedTasks = [NSMutableArray arrayWithArray:self.tasks];
		if (waypointOrder.count > 1) {
			NSInteger index = 1;
			for (NSNumber *orderNum in waypointOrder) {
				NSInteger order = orderNum.integerValue;
				[organizedTasks replaceObjectAtIndex:index withObject:[self.tasks objectAtIndex:order+1]];
				index++;
			}
		}
		
		TaskAnnotation *startAnnotation = [[[TaskAnnotation alloc] initWithCoordinate:[[[route legAtIndex:0]startLocation]coordinate]
																						title:[[organizedTasks objectAtIndex:0]name]
																					 subtitle:[[route legAtIndex:0]startAddress]
																			   annotationType:UICRouteAnnotationTypeStart] autorelease];
		startAnnotation.task = [organizedTasks objectAtIndex:0];
		[self.mapView addAnnotation:startAnnotation];
		
		for (NSInteger index = 0; index < route.numberOfLegs; index++) {
			if (index == route.numberOfLegs - 1) {
				break;
			}
			
			UICGLeg *leg = [route legAtIndex:index];
			TaskAnnotation *annotation = [[[TaskAnnotation alloc] initWithCoordinate:leg.endLocation.coordinate
																					   title:[[organizedTasks objectAtIndex:index + 1]name]
																					subtitle:leg.endAddress
																			  annotationType:UICRouteAnnotationTypeWayPoint] autorelease];
			annotation.task = [organizedTasks objectAtIndex:index + 1];
			[self.mapView addAnnotation:annotation];
			
		}
		
		TaskAnnotation *endAnnotation = [[[TaskAnnotation alloc] initWithCoordinate:[[[route.legs lastObject]endLocation]coordinate]
																					  title:[[organizedTasks lastObject]name]
																				   subtitle:[[route.legs lastObject]endAddress]
																			 annotationType:UICRouteAnnotationTypeEnd] autorelease];
		
		endAnnotation.task = [organizedTasks lastObject];
		[self.mapView addAnnotation:endAnnotation];
	}
}

- (void)directions:(UICGDirections *)directions didFailWithMessage:(NSString *)message {
	[self performSelectorOnMainThread:@selector(baseLoadingViewCenterDidStopForKey:) withObject:@"direction" waitUntilDone:FALSE];
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Map Directions" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[alertView show];
	[alertView release];
}

#pragma mark -
#pragma mark Map View Delegate + Utilities

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:TRUE];
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:FALSE];
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:FALSE];
}

#pragma mark -
#pragma mark <MKMapViewDelegate> Methods

- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id<MKAnnotation>)annotation {
	static NSString *identifier = @"RoutePinAnnotation";
	
	if ([annotation isKindOfClass:[UICRouteAnnotation class]]) {
		MKPinAnnotationView *pinAnnotation = (MKPinAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:identifier];
		if(!pinAnnotation) {
			pinAnnotation = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
		}
		
		if ([(UICRouteAnnotation *)annotation annotationType] == UICRouteAnnotationTypeStart) {
			pinAnnotation.pinColor = MKPinAnnotationColorGreen;
		} else if ([(UICRouteAnnotation *)annotation annotationType] == UICRouteAnnotationTypeEnd) {
			pinAnnotation.pinColor = MKPinAnnotationColorRed;
		} else {
			pinAnnotation.pinColor = MKPinAnnotationColorPurple;
		}
		
		if (![annotation.title isEqualToString:CURRENT_LOCATION_PLACEHOLDER] && 
			[(UICRouteAnnotation *)annotation annotationType] != UICRouteAnnotationTypeStart) {
			UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
			pinAnnotation.rightCalloutAccessoryView = button;
		}
		
		pinAnnotation.animatesDrop = YES;
		pinAnnotation.enabled = YES;
		pinAnnotation.canShowCallout = YES;
		return pinAnnotation;
	}
	
	return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	if ([view.annotation isKindOfClass:[TaskAnnotation class]]) {
		TaskAnnotation *annotation = (TaskAnnotation *)view.annotation;
		Task *task = annotation.task;
		
		TaskContainerViewController *controller = [[[TaskContainerViewController alloc]initWithNibName:@"TaskContainerView" bundle:nil]autorelease];
		controller.hidesBottomBarWhenPushed = TRUE;
		controller.task = task;
		controller.tasks = self.tasks;
		[self.mainNavController pushViewController:controller animated:TRUE];
	}
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
	MKOverlayView* overlayView = nil;
	if(overlay == self.routeLine) {
		//if we have not yet created an overlay view for this overlay, create it now. 
		if(nil == self.routeLineView) {
			self.routeLineView = [[[MKPolylineView alloc] initWithPolyline:self.routeLine] autorelease];
			self.routeLineView.strokeColor = [UIColor colorWithHexString:@"0000ff50"];
			self.routeLineView.fillColor = [UIColor colorWithHexString:@"0000ff"];
			self.routeLineView.lineWidth = 4.0;
		}
		overlayView = self.routeLineView;
	}
	return overlayView;
}

#pragma mark -
#pragma mark Actions

- (void)showCurrentLocation
{
	CLLocation *location = self.mapView.userLocation.location;
	if (!location && self.mapView.userLocation.updating) {
		[self performSelector:@selector(showCurrentLocation) withObject:nil afterDelay:0.5];
	} else {
		if (!self.mapView.showsUserLocation) {
			self.mapView.showsUserLocation = TRUE;
			[self performSelector:@selector(showCurrentLocation) withObject:nil afterDelay:0.5];
		} else {
			// zoom to current location
			[self.mapView setRegion:MKCoordinateRegionMakeWithDistance(location.coordinate, MapViewLocationDefaultSpanInMeters, MapViewLocationDefaultSpanInMeters) animated:TRUE];
		}
	}
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:FALSE];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:TasksWithinDidLoadNotification];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:TasksDidLoadNotification];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:TasksDueTodayDidLoadNotification];
	
	self.mapView.delegate = nil;
	self.directions.delegate = nil;
	
	[routeLine release];
	[routeLineView release];
	
	[customSearchBar release];
	
	[group release];
	
	[tasks release];
	[mapView release];
	
	[super dealloc];
}


@end
