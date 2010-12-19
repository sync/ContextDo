#import <UIKit/UIKit.h>
#import "MyLocationGetter.h"

@interface AppDelegate : NSObject <UIApplicationDelegate, MKReverseGeocoderDelegate, UINavigationControllerDelegate> {
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, readonly) UINavigationController *loginNavigationController;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, readonly) MyLocationGetter *locationGetter;
@property (nonatomic, readonly) CLLocation *currentLocation;

@property (nonatomic, readonly) BOOL hasValidCurrentLocation;

@property (nonatomic, readonly) MKPlacemark *placemark;
@property (nonatomic, readonly) MKReverseGeocoder *reverseGeocoder;

@property (nonatomic) BOOL firstGPSFix;

- (void)hideLoginView:(BOOL)animated;
- (void)showLoginView:(BOOL)animated;

+ (AppDelegate *)sharedAppDelegate;

@end

