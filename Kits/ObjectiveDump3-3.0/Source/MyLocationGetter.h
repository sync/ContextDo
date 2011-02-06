#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

// GPS
#define GPSLocationDidFix @"GPSLocationDidFix"
#define GPSLocationDidStop @"GPSLocationDidStop"
#define GPSLocationFinding @"GPSLocationFinding"

@interface MyLocationGetter : NSObject <CLLocationManagerDelegate> {
}

@property (nonatomic, readonly) CLLocationManager *locationManager;

- (void)startUpdates;
- (void)stopUpdates;

@end
