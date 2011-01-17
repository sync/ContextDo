#import <Foundation/Foundation.h>
#import "BaseTableViewController.h"
#import "GroupsEditDataSource.h"

@interface GroupsEditViewController : BaseTableViewController <GroupsEditDataSourceDelegate> {

}

@property (nonatomic, retain) GroupsEditDataSource *groupsEditDataSource;

@property (nonatomic, readonly) NSMutableArray *groups;

- (void)refreshDataSource;

@end
