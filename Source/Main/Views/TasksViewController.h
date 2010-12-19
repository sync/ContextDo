#import <UIKit/UIKit.h>
#import "BaseTableViewRefreshController.h"
#import "TasksDataSource.h"


@interface TasksViewController : BaseTableViewRefreshController {

}

@property (nonatomic, retain) TasksDataSource *tasksDataSource;

@property (nonatomic) NSInteger page;

@property (nonatomic, readonly) NSMutableArray *tasks;

@property (nonatomic, retain) Group *group;

@end
