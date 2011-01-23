#import <Foundation/Foundation.h>
#import "BaseTableViewController.h"
#import "TaskDatePickerDataSource.h"

@interface TaskDatePickerViewController : BaseTableViewController {

}

@property (nonatomic, retain) IBOutlet UIDatePicker *datePicker;

@property (nonatomic, retain) Task *task;

@property (nonatomic, retain) TaskDatePickerDataSource *taskDatePickerDataSource;

@property (nonatomic,retain) UISwitch *onOffSwitch;

- (void)refreshTask;

@end
