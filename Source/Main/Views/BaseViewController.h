#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
#import "BaseLoadingViewCenter.h"

@interface BaseViewController : UIViewController <BaseLoadingViewCenterDelegate, MBProgressHUDDelegate>{
	MBProgressHUD *_loadingView;
	MBProgressHUD *_noResultsView;
}

- (void)setupCustomInitialisation;

- (void)setupNavigationBar;
- (void)setupToolbar;

- (void)locationDidFix;
- (void)locationDidStop;

- (void)shouldReloadContent:(NSNotification *)notification;

@property (nonatomic, retain) MBProgressHUD *loadingView;
@property (nonatomic, retain) MBProgressHUD *noResultsView;

@property (nonatomic, readonly) BOOL isNetworkReachable;

@end
