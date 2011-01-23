#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import "GroupsDataSource.h"
#import "GroupsEditViewController.h"
#import "CTXDODarkTextField.h"
#import "InfoViewController.h"

@interface GroupsViewController : BaseTableViewController <UITextFieldDelegate> {

}

@property (nonatomic, retain) GroupsDataSource *groupsDataSource;

@property (nonatomic, readonly) NSMutableArray *groups;

@property (nonatomic, readonly) GroupsEditViewController *groupsEditViewController;
@property (nonatomic, readonly) BOOL isShowingGroupsEdit;
@property (nonatomic, readonly) InfoViewController *infoViewController;
@property (nonatomic, readonly) BOOL isShowingInfoView;

@property (nonatomic, retain) IBOutlet CTXDODarkTextField *addGroupTextField;

@end
