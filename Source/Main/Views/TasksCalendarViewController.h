#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import <TapkuLibrary/TapkuLibrary.h>
#import "MBProgressHUD.h"
#import "TasksCalendarDataSource.h"

@interface TasksCalendarViewController : TKCalendarMonthTableViewController {

}

@property (nonatomic, retain) NSArray *tasks;

@property (nonatomic, readonly) BOOL isTodayTasks;
@property (nonatomic, readonly) BOOL isNearTasks;

@property (nonatomic,  assign) UINavigationController *mainNavController;

@property (nonatomic, retain) TasksCalendarDataSource *tasksCalendarDataSource;

- (void)setupDataSource;

- (void)refreshTasks;

@end
