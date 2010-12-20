#import <UIKit/UIKit.h>
#import "BaseTableViewRefreshController.h"
#import "GroupsDataSource.h"

@interface GroupsViewController : BaseTableViewRefreshController <GroupsDataSourceDelegate> {

}

@property (nonatomic, retain) GroupsDataSource *groupsDataSource;

@property (nonatomic) NSInteger page;

@property (nonatomic, readonly) NSMutableArray *groups;

@end
