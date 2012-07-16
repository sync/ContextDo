#import <UIKit/UIKit.h>
#import "MyLocationGetter.h"
#import "BWHockeyManager.h"

@interface AppDelegate : NSObject <UIApplicationDelegate, UINavigationControllerDelegate, BWHockeyManagerDelegate> {
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, readonly) UINavigationController *loginNavigationController;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, readonly) MyLocationGetter *locationGetter;
@property (nonatomic, readonly) CLLocation *currentLocation;
@property (nonatomic, retain) CLLocation *lastCurrentLocation;

@property (nonatomic, readonly) BOOL hasValidCurrentLocation;

@property (nonatomic, readonly) CLPlacemark *placemark;
@property (nonatomic, readonly) CLGeocoder *reverseGeocoder;

@property (nonatomic) BOOL firstGPSFix;

- (void)hideLoginView:(BOOL)animated;
- (void)showLoginView:(BOOL)animated;
- (void)logout:(BOOL)showingLogin animated:(BOOL)animated;;

- (void)showTask:(Task *)task animated:(BOOL)animated;
- (void)showNearTasksAnimated:(BOOL)animated;

@property (nonatomic, readonly) BOOL isBlackingOutTopViewElements;
- (void)blackOutTopViewElementsAnimated:(BOOL)animated;
- (void)hideBlackOutTopViewElementsAnimated:(BOOL)animated;
@property (nonatomic, assign) UIView *blackedOutView;

@property (nonatomic) BOOL backgrounding;

+ (AppDelegate *)sharedAppDelegate;

@end

