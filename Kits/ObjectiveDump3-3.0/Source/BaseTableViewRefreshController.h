#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import "EGORefreshTableHeaderView.h"

@interface BaseTableViewRefreshController : BaseTableViewController <EGORefreshTableHeaderDelegate> {

}

@property (nonatomic, readonly) EGORefreshTableHeaderView *refreshHeaderView;

- (void)hideRefreshHeaderView;

@end
