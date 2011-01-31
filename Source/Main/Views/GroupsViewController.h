#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import "GroupsDataSource.h"
#import "GroupsEditViewController.h"
#import "CTXDODarkTextField.h"
#import "InfoViewController.h"
#import "CTXDOTableViewRefreshController.h"

@interface GroupsViewController : CTXDOTableViewRefreshController <UITextFieldDelegate> {

}

@property (nonatomic, retain) GroupsDataSource *groupsDataSource;

@property (nonatomic, readonly) NSMutableArray *groups;

@property (nonatomic, readonly) GroupsEditViewController *groupsEditViewController;
@property (nonatomic, readonly) BOOL isShowingGroupsEdit;
@property (nonatomic, readonly) InfoViewController *infoViewController;
@property (nonatomic, readonly) BOOL isShowingInfoView;
@property (nonatomic, assign) UIView *blackedOutView;

@property (nonatomic, retain) IBOutlet CTXDODarkTextField *addGroupTextField;

@property (nonatomic, retain) CLLocation *lastCurrentLocation;

@end
