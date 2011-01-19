#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TasksViewController.h"

@interface TasksContainerViewController : BaseViewController {

}

@property (nonatomic, retain) IBOutlet UINavigationController *containerNavController;

@property (nonatomic, readonly) TasksViewController *tasksViewController;

@property (nonatomic, retain) Group *group;

@end
