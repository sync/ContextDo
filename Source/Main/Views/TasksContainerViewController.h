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

@property (nonatomic, retain) Group *group;
@property (nonatomic, retain) NSArray *tasks;

@property (nonatomic, readonly) BOOL isTodayTasks;
@property (nonatomic, readonly) BOOL isNearTasks;

@property (nonatomic) BOOL showCloseButton;

@end
