#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"

@interface TasksCalendarViewController : BaseTableViewController {

}

@property (nonatomic, retain) NSArray *tasks;

@property (nonatomic, retain) Group *group;

@property (nonatomic, readonly) BOOL isTodayTasks;
@property (nonatomic, readonly) NSString *nowDue;

@property (nonatomic,  assign) UINavigationController *mainNavController;

- (void)refreshTasks;

@end
