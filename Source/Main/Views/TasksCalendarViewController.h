#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import <TapkuLibrary/TapkuLibrary.h>
#import "MBProgressHUD.h"
#import "BaseLoadingViewCenter.h"
#import "TasksCalendarDataSource.h"

@interface TasksCalendarViewController : TKCalendarMonthTableViewController <BaseLoadingViewCenterDelegate, MBProgressHUDDelegate> {

}

@property (nonatomic, retain) MBProgressHUD *loadingView;
@property (nonatomic, retain) MBProgressHUD *noResultsView;

@property (nonatomic, retain) NSArray *tasks;

@property (nonatomic, retain) Group *group;

@property (nonatomic, readonly) BOOL isTodayTasks;
@property (nonatomic, readonly) BOOL isNearTasks;
- (NSString *)calendarMonthForDate:(NSDate *)date;

@property (nonatomic,  assign) UINavigationController *mainNavController;

@property (nonatomic, retain) TasksCalendarDataSource *tasksCalendarDataSource;

- (void)setupDataSource;

- (void)refreshTasks;

@end
