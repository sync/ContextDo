#import <Foundation/Foundation.h>
#import "BaseTableViewDataSource.h"

@protocol GroupsDataSourceDelegate;

@interface GroupsDataSource : BaseTableViewDataSource {

}

- (Group *)groupForIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, assign) id<GroupsDataSourceDelegate> delegate;

@end

@protocol GroupsDataSourceDelegate <NSObject>

- (void)groupsDataSource:(GroupsDataSource *)dataSource commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;

@end
