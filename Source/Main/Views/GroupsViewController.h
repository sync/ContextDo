#import <UIKit/UIKit.h>
#import "BaseTableViewRefreshController.h"
#import "GroupsDataSource.h"
#import "GroupsEditViewController.h"

@interface GroupsViewController : BaseTableViewRefreshController {

}

@property (nonatomic, retain) GroupsDataSource *groupsDataSource;

@property (nonatomic) NSInteger page;

@property (nonatomic, readonly) NSMutableArray *groups;

@property (nonatomic, readonly) GroupsEditViewController *groupsEditViewController;
@property (nonatomic, readonly) BOOL isShowingGroupsEdit;
@property (nonatomic, readonly) UIBarButtonItem *saveButtonItem;

@end
