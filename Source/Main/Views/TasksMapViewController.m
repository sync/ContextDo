#import "TasksMapViewController.h"
#import "UICRouteAnnotation.h"

@interface TasksMapViewController (private)

- (void)showCurrentLocation;
- (void)updateDirections;
- (void)refreshTasks;

@end

@implementation TasksMapViewController

@synthesize mapView, tasks, routeOverlayView, directions, customSearchBar, group, mainNavController;

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
	
	self.view.backgroundColor = [DefaultStyleSheet sharedDefaultStyleSheet].taskDarkGrayColor;
	
	self.mapView.showsUserLocation = TRUE;
	
	if (!self.isTodayTasks) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:TasksDidLoadNotification object:nil];
		[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:TasksDidLoadNotification];
	} else {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:TasksDueDidLoadNotification object:nil];
		[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:TasksDueDidLoadNotification];
	}
	[self refreshTasks];
}

#pragma mark -
#pragma mark Actions

- (void)refreshTasks
{
	if (!self.isTodayTasks) {
		[[APIServices sharedAPIServices]refreshTasksWithGroupId:self.group.groupId page:1];
	} else {
		[[APIServices sharedAPIServices]refreshTasksWithDue:self.nowDue page:1];
	}
}

#pragma mark -
#pragma mark Content reloading

- (void)shouldReloadContent:(NSNotification *)notification
{
	NSDictionary *dict = [notification object];
	
	NSArray *newTasks = [dict valueForKey:@"tasks"];
	self.tasks = newTasks;
	
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
	[self.routeOverlayView removeFromSuperview];
	self.routeOverlayView = nil;
	self.routeOverlayView = [[[UICRouteOverlayMapView alloc] initWithMapView:self.mapView]autorelease];
	self.directions = [UICGDirections sharedDirections];
	self.directions.delegate = self;
	
	UICGDirectionsOptions *options = [[[UICGDirectionsOptions alloc] init] autorelease];
	options.travelMode = UICGTravelModeDriving;
	
	
	CLLocation *startLocation = nil;
	if (TARGET_IPHONE_SIMULATOR) {
		startLocation = [AppDelegate sharedAppDelegate].currentLocation;
	} else {
		startLocation = self.mapView.userLocation.location;
	}
	
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
	[routeOverlayView setRoutes:routePoints];
	
	UICGRoute *route = [aDirections routeAtIndex:0];
	
	// Add annotations
	UICRouteAnnotation *startAnnotation = [[[UICRouteAnnotation alloc] initWithCoordinate:[[routePoints objectAtIndex:0] coordinate]
																					title:@"Current Location"
																				 subtitle:[[route.legs objectAtIndex:0]startAddress]
																		   annotationType:UICRouteAnnotationTypeStart] autorelease];
	UICRouteAnnotation *endAnnotation = [[[UICRouteAnnotation alloc] initWithCoordinate:[[routePoints lastObject] coordinate]
																				  title:@"TODO"
																			   subtitle:[[route.legs objectAtIndex:0]endAddress]
																		 annotationType:UICRouteAnnotationTypeEnd] autorelease];
	
	[self.mapView addAnnotations:[NSArray arrayWithObjects:startAnnotation, endAnnotation, nil]];
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

#pragma mark <MKMapViewDelegate> Methods

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
	self.routeOverlayView.hidden = YES;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
	self.routeOverlayView.hidden = NO;
	[self.routeOverlayView setNeedsDisplay];
}

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
		
		pinAnnotation.animatesDrop = YES;
		pinAnnotation.enabled = YES;
		pinAnnotation.canShowCallout = YES;
		return pinAnnotation;
	}
	
	return nil;
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
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:TasksDidLoadNotification];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:TasksDueDidLoadNotification];
	
	self.mapView.delegate = nil;
	self.directions.delegate = nil;
	
	[customSearchBar release];
	
	[group release];
	[mainNavController release];
	[tasks release];
	[mapView release];
	
	[super dealloc];
}


@end
