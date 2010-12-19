#import <Foundation/Foundation.h>
#import "BaseTableViewDataSource.h"

@interface TasksDataSource : BaseTableViewDataSource {

}

- (Task *)taskForIndexPath:(NSIndexPath *)indexPath;

@end
