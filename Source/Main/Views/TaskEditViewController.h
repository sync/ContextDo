#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import "TaskEditDataSource.h"

@interface TaskEditViewController : BaseTableViewController <UITextFieldDelegate> {

}

@property (nonatomic, retain) Task *task;

@property (nonatomic, retain) TaskEditDataSource *taskEditDataSource;

@property (nonatomic, retain) UITextField *editingTextField;
@property (nonatomic) BOOL keyboardShown;

@end
