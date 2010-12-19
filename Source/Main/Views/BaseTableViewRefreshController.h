#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import "EGORefreshTableHeaderView.h"

@interface BaseTableViewRefreshController : BaseTableViewController {

}

@property (nonatomic, readonly) EGORefreshTableHeaderView *refreshHeaderView;

- (void)showRefreshHeaderView;
- (void)hideRefreshHeaderView;

@end
