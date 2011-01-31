#import <UIKit/UIKit.h>
#import "BaseTableViewRefreshController.h"
#import "CTXDORefreshTableHeaderView.h"
#import "TISwipeableTableView.h"

@interface CTXDOTableViewRefreshController : BaseTableViewRefreshController <TISwipeableTableViewDelegate> {
	EGORefreshTableHeaderView *refreshHeaderView;
	
	id _delegate;
	EGOPullRefreshState _state;
	
	UILabel *_lastUpdatedLabel;
	UILabel *_statusLabel;
	CALayer *_arrowImage;
	UIActivityIndicatorView *_activityView;
}

@property (nonatomic) CGFloat refreshHeaderOffset;

//@property (nonatomic, readonly) TISwipeableTableView *swipeableTableView;

@end
