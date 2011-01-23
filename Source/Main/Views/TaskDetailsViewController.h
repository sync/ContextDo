#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface TaskDetailsViewController : BaseViewController {

}

@property (nonatomic, retain) Task *task;

- (void)refreshTask;

@end
