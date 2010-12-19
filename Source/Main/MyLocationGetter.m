#import "MyLocationGetter.h"

@implementation MyLocationGetter

@synthesize alwaysOn=_alwaysOn;
- (id) init
{
	self = [super init];
	if (self != nil) {
		self.alwaysOn = FALSE;
	}
	return self;
}


- (CLLocationManager *)locationManager
{
	if (!_locationManager) {
		_locationManager = [[CLLocationManager alloc] init];
		
		_locationManager.delegate = self;
		if (self.alwaysOn) {
			_locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
		} else {
			_locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
		}
		
		// Set a movement threshold for new events
		if (self.alwaysOn) {
			_locationManager.distanceFilter = kCLDistanceFilterNone;
		} else {
			_locationManager.distanceFilter = 500;
		}
		
	}
	return _locationManager;
}

- (void)startUpdates
{	
   [self.locationManager startUpdatingLocation];	
}

- (void)stopUpdates
{	
    [self.locationManager stopUpdatingLocation];
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
	
	NSDate* eventDate = newLocation.timestamp;
	NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
	if (howRecent <= -(60*60*24))
	{
		// If it is older than one day don't care about this value
		return;
	}
	
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

- (void)dealloc {
	[_locationManager release];
	
	[super dealloc];
}

@end
