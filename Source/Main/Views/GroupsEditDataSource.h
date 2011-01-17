#import <UIKit/UIKit.h>
#import "BaseTableViewDataSource.h"

@protocol GroupsEditDataSourceDelegate;

@interface GroupsEditDataSource : BaseTableViewDataSource {

}

- (Group *)groupForIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, assign) id<GroupsEditDataSourceDelegate> delegate;

@end

@protocol GroupsEditDataSourceDelegate <NSObject>

- (void)groupsEditDataSource:(GroupsEditDataSource *)dataSource commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;

@end
