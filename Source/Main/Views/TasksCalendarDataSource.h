#import <UIKit/UIKit.h>
#import "BaseTableViewDataSource.h"

@interface TasksCalendarDataSource : BaseTableViewDataSource {

}

- (Task *)taskForIndexPath:(NSIndexPath *)indexPath;

@end
