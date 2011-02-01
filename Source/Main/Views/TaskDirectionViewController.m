#import "TaskDirectionViewController.h"
#import "UICRouteAnnotation.h"
#import "UICRouteOverlay.h"

@interface TaskDirectionsViewController (private)

- (void)showCurrentLocation;
- (void)updateDirections;

@end

@implementation TaskDirectionsViewController

@synthesize mapView, task, directions, startPoint, endPoint, mainNavController;
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
	
	self.mapView.showsUserLocation = TRUE;
	[self refreshTask];
}

- (void)refreshTask
{
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
	
	
	CLLocation *startLocation = nil;
	if (TARGET_IPHONE_SIMULATOR) {
		startLocation = [AppDelegate sharedAppDelegate].currentLocation;
	} else {
		startLocation = self.mapView.userLocation.location;
	}
	
	self.startPoint = [self stringForLatitude:[AppDelegate sharedAppDelegate].currentLocation.coordinate.latitude
									longitude:[AppDelegate sharedAppDelegate].currentLocation.coordinate.longitude];
	self.endPoint = [self.task latLngString];
	[self updateDirections];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	
	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:FALSE];
	self.mapView = nil;
}



- (void)updateDirections
{
	UICGDirectionsOptions *options = [[[UICGDirectionsOptions alloc] init] autorelease];
	options.travelMode = UICGTravelModeDriving;
	[self.directions loadWithStartPoint:self.startPoint endPoint:self.endPoint options:options];
}

#pragma mark -
#pragma mark UICGDirectionsDelegate

- (void)directionsDidUpdateDirections:(UICGDirections *)aDirections {
	// Overlay polylines
	UICGPolyline *polyline = [[aDirections routeAtIndex:0] overviewPolyline];
	NSArray *routePoints = [polyline points];
	
	if (routePoints.count == 0) {
		// add all tasks
		CLLocation *location = [[[CLLocation alloc]initWithLatitude:self.task.latitude.doubleValue longitude:self.task.longitude.doubleValue]autorelease];
		TaskAnnotation *annotation = [[[TaskAnnotation alloc] initWithCoordinate:[location coordinate]
																		   title:self.task.name
																		subtitle:self.task.location
																  annotationType:UICRouteAnnotationTypeWayPoint] autorelease];
		
		annotation.task = self.task;
		[self.mapView addAnnotation:annotation];
		// zoom to current point
		[self.mapView setRegion:MKCoordinateRegionMakeWithDistance(location.coordinate, MapViewLocationDefaultSpanInMeters, MapViewLocationDefaultSpanInMeters) animated:TRUE];

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
		
		// Add annotations
		UICRouteAnnotation *startAnnotation = [[[UICRouteAnnotation alloc] initWithCoordinate:[[routePoints objectAtIndex:0] coordinate]
																						title:CURRENT_LOCATION_PLACEHOLDER
																					 subtitle:[[route.legs objectAtIndex:0]startAddress]
																			   annotationType:UICRouteAnnotationTypeStart] autorelease];
		UICRouteAnnotation *endAnnotation = [[[UICRouteAnnotation alloc] initWithCoordinate:[[routePoints lastObject] coordinate]
																					  title:self.task.name
																				   subtitle:[[route.legs objectAtIndex:0]endAddress]
																			 annotationType:UICRouteAnnotationTypeEnd] autorelease];
		[self.mapView addAnnotations:[NSArray arrayWithObjects:startAnnotation, endAnnotation, nil]];
	} else {
		CLLocation *location = [[[CLLocation alloc]initWithLatitude:self.task.latitude.doubleValue longitude:self.task.longitude.doubleValue]autorelease];
		TaskAnnotation *annotation = [[[TaskAnnotation alloc] initWithCoordinate:[location coordinate]
																		   title:self.task.name
																		subtitle:self.task.location
																  annotationType:UICRouteAnnotationTypeWayPoint] autorelease];
		
		annotation.task = self.task;
		[self.mapView addAnnotation:annotation];
		// zoom to current point
		[self.mapView setRegion:MKCoordinateRegionMakeWithDistance(location.coordinate, MapViewLocationDefaultSpanInMeters, MapViewLocationDefaultSpanInMeters) animated:TRUE];

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
	
	[startPoint release];
	[endPoint release];
	
	[task release];
	[mapView release];
	
	[super dealloc];
}

@end
