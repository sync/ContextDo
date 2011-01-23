#import "TaskDirectionViewController.h"

@interface TaskDirectionsViewController (private)

- (void)showCurrentLocation;

@end

@implementation TaskDirectionsViewController

@synthesize mapView, currentAnnotation, task;

#pragma mark -
#pragma mark Setup

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	self.mapView.showsUserLocation = TRUE;
	
	// Add new contact show popover
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = self.task.latitude.doubleValue;
	coordinate.longitude = self.task.longitude.doubleValue;
	self.currentAnnotation = [[[TaskAnnotation alloc]initWithCoordinate:coordinate]autorelease];
	self.currentAnnotation.task = self.task;
	self.currentAnnotation.title = self.task.name;
	self.currentAnnotation.subtitle = self.task.location;
	[self.mapView addAnnotation:self.currentAnnotation];
	[self.mapView setRegion:MKCoordinateRegionMakeWithDistance(self.currentAnnotation.coordinate, MapViewLocationDefaultSpanInMeters, MapViewLocationDefaultSpanInMeters) animated:TRUE];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	
	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:FALSE];
	self.mapView = nil;
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

- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	if ([annotation respondsToSelector:@selector(task)]) {
		static NSString *defaultPinID = @"DefaultPinID";
		
		MKPinAnnotationView *mkav = (MKPinAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
		if (mkav == nil) {
			mkav = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID] autorelease];
			mkav.canShowCallout = TRUE;
			mkav.pinColor = MKPinAnnotationColorPurple;
		}
		
		return mkav;
	}
	return nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
	CGRect visibleRect = [self.mapView annotationVisibleRect]; 
    for (MKAnnotationView *view in views) {
		TaskAnnotation *annotation = (TaskAnnotation *)view.annotation;
		if ([annotation respondsToSelector:@selector(task)]) {
			CGRect endingFrame = view.frame;
			CGRect startingFrame = endingFrame; 
			startingFrame.origin.y = visibleRect.origin.y - startingFrame.size.height;
			view.frame = startingFrame;
			[UIView beginAnimations:@"mapPin" context:NULL]; 
			[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
			[UIView setAnimationDuration:0.15];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(mapPinAnimationDidStop)];
			view.frame = endingFrame;
			[UIView commitAnimations];
		}
    }
}

- (void)mapPinAnimationDidStop
{
	[self.mapView selectAnnotation:self.currentAnnotation animated:TRUE];
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:FALSE];
	
	[task release];
	[currentAnnotation release];
	[mapView release];
	
	[super dealloc];
}

@end
