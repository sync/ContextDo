#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
#import "BaseLoadingViewCenter.h"
#import "UINavigationController+Custom.h"
#import "UISearchDisplayController+Custom.h"

@interface BaseViewController : UIViewController <BaseLoadingViewCenterDelegate, MBProgressHUDDelegate>{
}

- (void)setupCustomInitialisation;

- (void)setupNavigationBar;
- (void)setupToolbar;

- (void)locationDidFix;
- (void)locationDidStop;

- (void)shouldReloadContent:(NSNotification *)notification;

@property (nonatomic, retain) MBProgressHUD *loadingView;
@property (nonatomic, retain) MBProgressHUD *noResultsView;

@end
