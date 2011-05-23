#import <UIKit/UIKit.h>
#import "TasksDataSource.h"


@interface TasksViewController : BaseTableViewController {

}

@property (nonatomic, retain) TasksDataSource *tasksDataSource;

@property (nonatomic, retain) NSArray *tasks;
@property (nonatomic, retain) NSArray *tasksSave;

@property (nonatomic, readonly) BOOL isTodayTasks;
@property (nonatomic, readonly) BOOL isNearTasks;

@property (nonatomic,  assign) UINavigationController *mainNavController;

- (void)cancelSearch;

@end
