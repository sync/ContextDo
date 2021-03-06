#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import "GroupsDataSource.h"
#import "GroupsEditViewController.h"
#import "CTXDODarkTextField.h"
#import "InfoViewController.h"
#import "CTXDOTableViewRefreshController.h"
#import "TasksDataSource.h"

@interface GroupsViewController : CTXDOTableViewRefreshController <UITextFieldDelegate> {

}

@property (nonatomic, retain) GroupsDataSource *groupsDataSource;

@property (nonatomic, retain) NSArray *groups;

@property (nonatomic, retain) IBOutlet UIView *tableHeaderView;

@property (nonatomic, readonly) GroupsEditViewController *groupsEditViewController;
@property (nonatomic, readonly) BOOL isShowingGroupsEdit;
@property (nonatomic, readonly) InfoViewController *infoViewController;
@property (nonatomic, readonly) BOOL isShowingInfoView;
@property (nonatomic, assign) UIView *blackedOutView;

@property (nonatomic, retain) IBOutlet CTXDODarkTextField *addGroupTextField;

@property (nonatomic, retain) IBOutlet UIButton *infoButton;
- (IBAction)infoButtonPressed;

@property (nonatomic) BOOL hasCachedData;

@property (nonatomic, retain) IBOutlet CustomSearchBar *searchBar;
@property (nonatomic, retain) NSArray *tasks;
@property (nonatomic, retain) TasksDataSource *tasksDataSource;

@end
