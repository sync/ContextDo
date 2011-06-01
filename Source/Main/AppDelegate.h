#import <UIKit/UIKit.h>
#import "MyLocationGetter.h"

@interface AppDelegate : NSObject <UIApplicationDelegate, MKReverseGeocoderDelegate, UINavigationControllerDelegate> {
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, readonly) MyLocationGetter *locationGetter;
@property (nonatomic, readonly) CLLocation *currentLocation;
@property (nonatomic, retain) CLLocation *lastCurrentLocation;

@property (nonatomic, readonly) BOOL hasValidCurrentLocation;

@property (nonatomic, readonly) MKPlacemark *placemark;
@property (nonatomic, readonly) MKReverseGeocoder *reverseGeocoder;

@property (nonatomic) BOOL firstGPSFix;

- (void)showTask:(Task *)task animated:(BOOL)animated;
- (void)showNearTasksAnimated:(BOOL)animated;

@property (nonatomic) BOOL backgrounding;

+ (AppDelegate *)sharedAppDelegate;

@end

