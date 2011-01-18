#import <Foundation/Foundation.h>
#import "BaseTableViewDataSource.h"

@interface TasksDataSource : BaseTableViewDataSource {

}

- (Task *)taskForIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)tagForRow:(NSInteger)row;
- (NSInteger)rowForTag:(NSInteger)tag;

@end
