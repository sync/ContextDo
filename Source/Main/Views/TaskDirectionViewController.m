#import "TaskDirectionViewController.h"
#import "TaskAnnotation.h"
#import "UICRouteOverlay.h"

@interface TaskDirectionsViewController ()

- (void)showCurrentLocation;
- (void)updateDirections;
- (TaskAnnotation *)annotationForTask:(Task *)task;
- (void)addTaskAnnotation;
- (void)clearMapView;

@end

@implementation TaskDirectionsViewController

@synthesize mapView, task, directions, currentLocationTask, mainNavController;
@synthesize routeLine, routeLineView;

#pragma mark -
#pragma mark Setup

- (NSString *)stringForLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude
{
	return [NSString stringWithFormat:@"%f,%f", latitude, longitude];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	self.view.backgroundColor = [DefaultStyleSheet sharedDefaultStyleSheet].taskDarkGrayColor;
    
    self.directions = [UICGDirections sharedDirections];
	self.directions.delegate = self;
	
	self.mapView.showsUserLocation = TRUE;
	[self refreshTask];
}

- (void)refreshTask
{
    [self.mapView removeOverlay:self.routeLine];
    self.routeLineView = nil;
	
    if ([AppDelegate sharedAppDelegate].hasValidCurrentLocation) {
        CLLocation *startLocation = nil;
        if (TARGET_IPHONE_SIMULATOR) {
            startLocation = [AppDelegate sharedAppDelegate].currentLocation;
        } else {
            startLocation = self.mapView.userLocation.location;
        }
        
        self.currentLocationTask = [Task taskWithId:[NSNumber numberWithInteger:NSNotFound]
                                               name:CURRENT_LOCATION_PLACEHOLDER
                                           latitude:startLocation.coordinate.latitude
                                          longitude:startLocation.coordinate.longitude];
        
        [self updateDirections];
    } else {
        [self addTaskAnnotation];
    }
	
	
}

- (void)viewDidUnload {
	[super viewDidUnload];
	
	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:FALSE];
	self.mapView = nil;
}

- (TaskAnnotation *)annotationForTask:(Task *)aTask
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"class = %@ && task.taskId == %@", [TaskAnnotation class], aTask.taskId];
    NSArray *annotations = [self.mapView.annotations filteredArrayUsingPredicate:predicate];
    return (annotations.count > 0) ? [annotations objectAtIndex:0] : nil;
}

- (void)clearMapView
{
    NSArray *tasks = [NSArray arrayWithObjects:self.currentLocationTask.taskId, self.task.taskId, nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"class = %@ && not task.taskId in %@", [TaskAnnotation class], tasks];
    NSArray *annotations = [self.mapView.annotations filteredArrayUsingPredicate:predicate];
    [self.mapView removeAnnotations:annotations];
}

- (void)addTaskAnnotation
{
    CLLocation *location = [[[CLLocation alloc]initWithLatitude:self.task.latitude.doubleValue longitude:self.task.longitude.doubleValue]autorelease];
    
    TaskAnnotation *annotation = [self annotationForTask:self.task];
    if (!annotation) {
        annotation = [[[TaskAnnotation alloc] initWithCoordinate:[location coordinate]
                                                           title:self.task.name
                                                        subtitle:self.task.location
                                                  annotationType:UICRouteAnnotationTypeWayPoint] autorelease];
         [self.mapView addAnnotation:annotation];
    } else {
        annotation.title = self.task.name;
        annotation.subtitle = self.task.location;
        annotation.coordinate = location.coordinate;
    }
    annotation.task = self.task;
    
    [self clearMapView];
   
    // zoom to current point
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(location.coordinate, MapViewLocationDefaultSpanInMeters, MapViewLocationDefaultSpanInMeters) animated:TRUE];
}

- (void)updateDirections
{
	UICGDirectionsOptions *options = [[[UICGDirectionsOptions alloc] init] autorelease];
	options.travelMode = UICGTravelModeDriving;
	[self.directions loadWithStartPoint:self.currentLocationTask.latLngString endPoint:self.task.latLngString options:options];
}

#pragma mark -
#pragma mark UICGDirectionsDelegate

- (void)directionsDidUpdateDirections:(UICGDirections *)aDirections {
	// Overlay polylines
	UICGPolyline *polyline = [[aDirections routeAtIndex:0] overviewPolyline];
	NSArray *routePoints = [polyline points];
	
	if (routePoints.count == 0) {
		[self addTaskAnnotation];
		return;
	}
	
	UICRouteOverlay *overlay = [UICRouteOverlay routeOverlayWithPoints:routePoints];
	self.routeLine = overlay.polyline;
	[self.mapView addOverlay:self.routeLine];
	[self.mapView setVisibleMapRect:overlay.mapRect];
	
	// here we can have multiple routes todo
	NSInteger numberOfRoutes = [self.directions numberOfRoutes];
	if (numberOfRoutes > 0) {
		UICGRoute *route = [self.directions routeAtIndex:0];
		
		TaskAnnotation *startAnnotation = [self annotationForTask:self.currentLocationTask];
        if (!startAnnotation) {
            startAnnotation = [[[TaskAnnotation alloc] initWithCoordinate:[[routePoints objectAtIndex:0] coordinate]
                                                                    title:CURRENT_LOCATION_PLACEHOLDER
                                                                 subtitle:[[route.legs objectAtIndex:0]startAddress]
                                                           annotationType:UICRouteAnnotationTypeStart] autorelease];
            [self.mapView addAnnotation:startAnnotation];
        } else {
            startAnnotation.title = self.currentLocationTask.name;
            startAnnotation.subtitle = [[route.legs objectAtIndex:0]startAddress];
            startAnnotation.coordinate = [[routePoints objectAtIndex:0] coordinate];
        }
        startAnnotation.task = self.currentLocationTask;
        
        TaskAnnotation *endAnnotation = [self annotationForTask:self.task];
        if (!endAnnotation) {
            endAnnotation = [[[TaskAnnotation alloc] initWithCoordinate:[[routePoints lastObject] coordinate]
                                                                  title:self.task.name
                                                               subtitle:self.task.location
                                                         annotationType:UICRouteAnnotationTypeEnd] autorelease];
            [self.mapView addAnnotation:endAnnotation];
        } else {
            endAnnotation.title = self.task.name;
            endAnnotation.subtitle = self.task.location;
            endAnnotation.coordinate = [[routePoints lastObject] coordinate];
        }
        endAnnotation.task = self.task;
        
         [self clearMapView];
	} else {
		[self addTaskAnnotation];
	}
}

- (void)directions:(UICGDirections *)directions didFailWithMessage:(NSString *)message {
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
	
	if ([annotation isKindOfClass:[TaskAnnotation class]]) {
		MKPinAnnotationView *pinAnnotation = (MKPinAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:identifier];
		if(!pinAnnotation) {
			pinAnnotation = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
		}
		
		if ([(TaskAnnotation *)annotation annotationType] == UICRouteAnnotationTypeStart) {
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

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
	MKOverlayView* overlayView = nil;
	if(overlay == self.routeLine) {
		//if we have not yet created an overlay view for this overlay, create it now. 
		if(nil == self.routeLineView) {
			self.routeLineView = [[[MKPolylineView alloc] initWithPolyline:self.routeLine] autorelease];
			self.routeLineView.strokeColor = [UIColor colorWithHexString:@"0000ff50"];
			self.routeLineView.fillColor = [UIColor colorWithHexString:@"0000ff70"];
			
			CGFloat scale = 1.0;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
			if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
				scale = [[UIScreen mainScreen] scale];
			}
#endif
			self.routeLineView.lineWidth = 4.0 * scale;
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
	
	self.mapView.delegate = nil;
	self.directions.delegate = nil;
	
	[routeLine release];
	[routeLineView release];
	
	[currentLocationTask release];
	
	[task release];
	[mapView release];
	
	[super dealloc];
}

@end
