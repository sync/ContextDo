#import <UIKit/UIKit.h>
#import "BaseTableViewRefreshController.h"
#import "GroupsDataSource.h"


@interface GroupsViewController : BaseTableViewRefreshController {

}

@property (nonatomic, retain) GroupsDataSource *groupsDataSource;

@property (nonatomic) NSInteger page;

@property (nonatomic, readonly) NSMutableArray *groups;

- (void)reloadGroups:(NSArray *)newGroups removeCache:(BOOL)removeCache showMore:(BOOL)showMore;

@end
