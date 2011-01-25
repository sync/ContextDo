#import <UIKit/UIKit.h>
#import "TaskDatePickerViewController.h"

@interface TaskScheduleViewController : TaskDatePickerViewController {

}

@property (nonatomic,  assign) UINavigationController *mainNavController;
@property (nonatomic) BOOL userEdited;

@end
