#import "TaskLocationViewController.h"

@interface TaskLocationViewController ()

- (void)showCurrentLocation;
- (void)shouldReverseLocation:(CLLocation *)centerLocation;
- (void)setStreet:(NSString *)street suburb:(NSString *)suburb;

@end

@implementation TaskLocationViewController

@synthesize mapView, userEdited, placemark, reverseGeocoder, lastCenterLocation;

#pragma mark -
#pragma mark Initialisation

- (void)viewWillAppear:(BOOL)animated
{
	// nothing
}

- (void)viewDidLoad 
{
	[super viewDidLoad];
	
	self.title = @"Edit Location";
	
	CALayer *layer = [self.mapView layer];
	layer.masksToBounds = YES;
	[layer setCornerRadius:5.0];
	[layer setBorderWidth:1.0];
	[layer setBorderColor:[[UIColor colorWithHexString:@"bbb"] CGColor]];
	
	self.view.backgroundColor = [DefaultStyleSheet sharedDefaultStyleSheet].backgroundTexture;
	
	self.userEdited = (self.taskEditDataSource.tempTask.location.length  != 0);
	
	placemark = [[AppDelegate sharedAppDelegate].placemark retain];
	[self showCurrentLocation];
	
	
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	self.mapView = nil;
}

#pragma mark -
#pragma mark Setup

- (void)setupNavigationBar
{
	[super setupNavigationBar];
	
	self.navigationItem.leftBarButtonItem = [[DefaultStyleSheet sharedDefaultStyleSheet] backItemWithText:@"Back"
																								   target:self.navigationController
																								 selector:@selector(customBackButtonTouched)];
    
    self.navigationItem.rightBarButtonItem = [[DefaultStyleSheet sharedDefaultStyleSheet]navBarButtonItemWithText:@"Clear"
																										   target:self
																										 selector:@selector(clearTouched)];
}

- (void)setupDataSource
{
	[super setupDataSource];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification object:nil];
	
	
	self.taskEditDataSource = [[[TaskLocationDataSource alloc]init]autorelease];
	self.tableView.dataSource = self.taskEditDataSource;
	self.tableView.backgroundColor = [DefaultStyleSheet sharedDefaultStyleSheet].backgroundTexture;
	self.taskEditDataSource.tempTask = self.task;
	self.tableView.sectionFooterHeight = 0.0;
	self.tableView.sectionHeaderHeight = 12.0;
	
	[self.taskEditDataSource.content addObject:[NSArray arrayWithObject:PlaceNamePlaceHolder]];
	[self.taskEditDataSource.content addObject:[NSArray arrayWithObject:StreetPlaceHolder]];
	[self.taskEditDataSource.content addObject:[NSArray arrayWithObject:SuburbPlaceHolder]];
	[self.tableView reloadData];
	//[self startEditing];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (!scrollView.dragging || scrollView.decelerating) {
		return;
	}
	
	[self endEditing];
}

#pragma mark -
#pragma mark Keyboard

- (void)keyboardWillShow:(NSNotification *)notification
{
	if (self.keyboardShown) {
		return;
	}
	
	self.keyboardShown = TRUE;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
	if (!self.keyboardShown) {
		return;
	}
	
	self.keyboardShown = FALSE;
}

#pragma mark -
#pragma mark Map View Delegate + Utilities

//- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
//{
//	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:TRUE];
//}
//
//- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
//{
//	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:FALSE];
//}
//
//- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
//{
//	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:FALSE];
//}

#define RegionShouldUpdateCloseThresholdInMeters 1

- (void)shouldReverseLocation:(CLLocation *)centerLocation
{
	if (!centerLocation) {
		return;
	}
	
	CLLocation *currentCenterLocation = [[[CLLocation alloc]initWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude]autorelease];
	CLLocationDistance distance = [centerLocation distanceFromLocation:currentCenterLocation];
	CLLocationDistance distanceFromLast = (self.lastCenterLocation) ? [centerLocation distanceFromLocation:self.lastCenterLocation] : NSNotFound;
	
	if (distance == 0 && distanceFromLast > RegionShouldUpdateCloseThresholdInMeters) {
		CLLocationCoordinate2D coordinate = self.mapView.centerCoordinate;
		if (reverseGeocoder) {
			[reverseGeocoder cancel];
			reverseGeocoder.delegate = nil;
			[reverseGeocoder release];
			reverseGeocoder = nil;
		}
		reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:coordinate];
		reverseGeocoder.delegate = self;
		[reverseGeocoder start];
		[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:TRUE];
	}
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{	
	CLLocation *currentCenterLocation = [[[CLLocation alloc]initWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude]autorelease];
	[self performSelector:@selector(shouldReverseLocation:) withObject:currentCenterLocation afterDelay:1.5];
}

#pragma mark -
#pragma mark MKReverseGeocoderDelegate methods

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)newPlacemark 
{
    self.lastCenterLocation = [[[CLLocation alloc]initWithLatitude:geocoder.coordinate.latitude longitude:geocoder.coordinate.longitude]autorelease];
	
	placemark = [newPlacemark retain];
    reverseGeocoder.delegate = nil;
	[reverseGeocoder release];
	reverseGeocoder = nil;
	
	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:FALSE];
	
	if (!self.userEdited) {
		NSString *street = @"";
		NSString *separator = @"";
		if (self.placemark.subThoroughfare.length > 0) {
			street = [street stringByAppendingString:self.placemark.subThoroughfare];
			separator = @" ";
		}
		if (self.placemark.thoroughfare.length > 0) {
			street = [street stringByAppendingFormat:@"%@%@", separator, self.placemark.thoroughfare];
		}
		NSString *suburb = (self.placemark.locality.length > 0) ? self.placemark.locality : self.placemark.subLocality;
		[self setStreet:street suburb:suburb];
	}
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error 
{
    [placemark release];
	placemark = nil;
	reverseGeocoder.delegate = nil;
	[reverseGeocoder release];
	reverseGeocoder = nil;
	
	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:FALSE];
}

#pragma mark -
#pragma mark Actions

- (void)setStreet:(NSString *)street suburb:(NSString *)suburb
{
	[self.taskEditDataSource setValue:street forIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
	[self.taskEditDataSource setValue:suburb forIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
	[self.tableView reloadData];
}

- (void)clearTouched
{
	self.taskEditDataSource.tempTask.location = nil;
	self.userEdited = FALSE;
	[self.taskEditDataSource setValue:nil forIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	[self setStreet:nil suburb:nil];
	
}

#define MapViewPlacesCloseSpanInMeters 300.0

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
			[self.mapView setRegion:MKCoordinateRegionMakeWithDistance(location.coordinate, MapViewPlacesCloseSpanInMeters, MapViewPlacesCloseSpanInMeters) animated:TRUE];
		}
	}
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [mapView release];
	[lastCenterLocation release];
	[placemark release];
	[reverseGeocoder release];
	
	[super dealloc];
}

@end
