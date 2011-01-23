#import <Foundation/Foundation.h>
#import "BaseTableViewDataSource.h"

@interface TasksUpdatedDataSource : BaseTableViewDataSource {

}

- (Task *)taskForIndexPath:(NSIndexPath *)indexPath;

@end
