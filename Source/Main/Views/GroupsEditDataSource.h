#import <UIKit/UIKit.h>
#import "BaseTableViewDataSource.h"

@protocol GroupsEditDataSourceDelegate;

@interface GroupsEditDataSource : BaseTableViewDataSource {

}

- (Group *)groupForIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, assign) id<GroupsEditDataSourceDelegate> delegate;

- (NSInteger)tagForRow:(NSInteger)row;
- (NSInteger)rowForTag:(NSInteger)tag;

@end

@protocol GroupsEditDataSourceDelegate <NSObject>

- (void)groupsEditDataSource:(GroupsEditDataSource *)dataSource commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)groupsEditDataSource:(GroupsEditDataSource *)dataSource moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;

@end
