#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TasksViewController.h"
#import "TasksMapViewController.h"
#import "TasksCalendarViewController.h"

@interface TasksContainerViewController : BaseViewController {

}

@property (nonatomic, retain) IBOutlet UINavigationController *containerNavController;
@property (nonatomic, retain) IBOutlet UIView *containerView;

@property (nonatomic, readonly) TasksViewController *tasksViewController;
@property (nonatomic, readonly) TasksMapViewController *tasksMapViewController;
@property (nonatomic, readonly) TasksCalendarViewController *tasksCalendarViewController;

- (void)showList;
- (void)showMap;
- (void)showCalendar;

@end
