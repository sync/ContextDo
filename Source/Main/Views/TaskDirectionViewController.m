#import "TaskDirectionViewController.h"
#import "UICRouteAnnotation.h"

@interface TaskDirectionsViewController (private)

- (void)showCurrentLocation;
- (void)updateDirections;

@end

@implementation TaskDirectionsViewController

@synthesize mapView, task, routeOverlayView, directions, startPoint, endPoint;

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
	
	// Test if its right around you less than 100 m??
	
//	// Add new contact show popover
//	CLLocationCoordinate2D coordinate;
//	coordinate.latitude = self.task.latitude.doubleValue;
//	coordinate.longitude = self.task.longitude.doubleValue;
//	self.currentAnnotation = [[[TaskAnnotation alloc]initWithCoordinate:coordinate]autorelease];
//	self.currentAnnotation.task = self.task;
//	self.currentAnnotation.title = self.task.name;
//	self.currentAnnotation.subtitle = self.task.location;
//	[self.mapView addAnnotation:self.currentAnnotation];
//	[self.mapView setRegion:MKCoordinateRegionMakeWithDistance(self.currentAnnotation.coordinate, MapViewLocationDefaultSpanInMeters, MapViewLocationDefaultSpanInMeters) animated:TRUE];
	
	//[self refreshTask];
}

- (void)refreshTask
{
	if (!self.view) {
		return;
	}
	
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
	
	self.startPoint = [self stringForLatitude:[AppDelegate sharedAppDelegate].currentLocation.coordinate.latitude
									longitude:[AppDelegate sharedAppDelegate].currentLocation.coordinate.longitude];
	self.endPoint = [self stringForLatitude:self.task.latitude.doubleValue
								  longitude:self.task.longitude.doubleValue];
	[self.directions loadWithStartPoint:self.startPoint endPoint:self.endPoint options:options];
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
																				  title:self.task.name
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

//- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>)annotation
//{
//	if ([annotation respondsToSelector:@selector(task)]) {
//		static NSString *defaultPinID = @"DefaultPinID";
//		
//		MKPinAnnotationView *mkav = (MKPinAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
//		if (mkav == nil) {
//			mkav = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID] autorelease];
//			mkav.canShowCallout = TRUE;
//			mkav.pinColor = MKPinAnnotationColorPurple;
//		}
//		
//		return mkav;
//	}
//	return nil;
//}
//
//- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
//	CGRect visibleRect = [self.mapView annotationVisibleRect]; 
//    for (MKAnnotationView *view in views) {
//		TaskAnnotation *annotation = (TaskAnnotation *)view.annotation;
//		if ([annotation respondsToSelector:@selector(task)]) {
//			CGRect endingFrame = view.frame;
//			CGRect startingFrame = endingFrame; 
//			startingFrame.origin.y = visibleRect.origin.y - startingFrame.size.height;
//			view.frame = startingFrame;
//			[UIView beginAnimations:@"mapPin" context:NULL]; 
//			[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//			[UIView setAnimationDuration:0.15];
//			[UIView setAnimationDelegate:self];
//			[UIView setAnimationDidStopSelector:@selector(mapPinAnimationDidStop)];
//			view.frame = endingFrame;
//			[UIView commitAnimations];
//		}
//    }
//}

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
	
	self.mapView.delegate = nil;
	self.directions.delegate = nil;
	
	[startPoint release];
	[endPoint release];
	
	[task release];
	[mapView release];
	
	[super dealloc];
}

@end
