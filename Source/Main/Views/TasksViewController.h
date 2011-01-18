#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import "TasksDataSource.h"

#define TodaysTasksPlacholder @"Todays tasks"


@interface TasksViewController : BaseTableViewController <UISearchDisplayDelegate> {

}

@property (nonatomic, retain) TasksDataSource *tasksDataSource;
@property (nonatomic, retain) TasksDataSource *searchTasksDataSource;

@property (nonatomic) NSInteger page;

@property (nonatomic, readonly) NSMutableArray *tasks;

@property (nonatomic, retain) Group *group;

@property (nonatomic, readonly) BOOL isTodayTasks;
@property (nonatomic, readonly) NSString *nowDue;

@end
