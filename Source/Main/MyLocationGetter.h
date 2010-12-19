#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

// GPS
#define GPSLocationDidStop @"GPSLocationDidStop"
#define GPSLocationDidFix @"GPSLocationDidFix"

@interface MyLocationGetter : NSObject <CLLocationManagerDelegate> {
	
	CLLocationManager *_locationManager;
	
	BOOL _alwaysOn;
}

@property (nonatomic, readonly) CLLocationManager *locationManager;
@property (nonatomic) BOOL alwaysOn;

- (void)startUpdates;
- (void)stopUpdates;

@end
