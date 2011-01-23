#import <Foundation/Foundation.h>
#import "BaseTableViewController.h"
#import "CTXDOSegmentControl.h"
#import "TaskScheduleViewController.h"
#import "TaskDirectionViewController.h"

@interface TaskContainerViewController : BaseTableViewController {

}

@property (nonatomic, retain) IBOutlet UINavigationController *containerNavController;
@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (nonatomic, retain) IBOutlet CTXDOSegmentControl *segmentControl;

@property (nonatomic, retain) NSArray *tasks;
@property (nonatomic, retain) Task *task;

@property (nonatomic, retain) IBOutlet TaskScheduleViewController *taskScheduleViewController;
@property (nonatomic, retain) IBOutlet TaskDirectionsViewController *taskDirectionsViewController;

@end
