#import "MyLocationGetter.h"
#import "BaseLoadingViewCenter.h"

@implementation MyLocationGetter

@synthesize locationManager;

- (CLLocationManager *)locationManager
{
	if (!locationManager) {
		locationManager = [[CLLocationManager alloc] init];
		
		locationManager.delegate = self;
		locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
		// Set a movement threshold for new events
		locationManager.distanceFilter = 500;
		
	}
	return locationManager;
}

- (void)startUpdates
{	
   [[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStartLoadingForKey:GPSLocationFinding];
	
	if ([CLLocationManager respondsToSelector:@selector(significantLocationChangeMonitoringAvailable)] &&
		[CLLocationManager significantLocationChangeMonitoringAvailable]) {
		[self.locationManager startMonitoringSignificantLocationChanges];
	} else {
		[self.locationManager startUpdatingLocation];
	}
}

- (void)stopUpdates
{	
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
		[self.locationManager stopMonitoringSignificantLocationChanges];
	} else {
		[self.locationManager stopUpdatingLocation];
	}
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStopLoadingForKey:GPSLocationFinding];
}


// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
    // Horizontal coordinates
	if (signbit(newLocation.horizontalAccuracy)) {
		// Invalid coordinate
		return;
	}
	
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStopLoadingForKey:GPSLocationFinding];
	
	// Tell everyone that gps got a fix
	[[NSNotificationCenter defaultCenter] postNotificationName:GPSLocationDidFix object:nil userInfo:nil];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	if ([error code] == kCLErrorDenied) {
		// should stop looking for coordinates
		[self.locationManager stopUpdatingLocation];
		[[NSNotificationCenter defaultCenter] postNotificationName:GPSLocationDidStop object:nil userInfo:nil];
	}
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc 
{
	[locationManager release];
	
	[super dealloc];
}

@end
