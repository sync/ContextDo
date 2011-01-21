#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import "TaskEditDataSource.h"

@interface TaskEditViewController : BaseTableViewController <UITextFieldDelegate, UITextViewDelegate> {

}

@property (nonatomic, retain) Task *task;

@property (nonatomic, retain) TaskEditDataSource *taskEditDataSource;

@property (nonatomic, retain) UITextField *editingTextField;
@property (nonatomic, retain) UITextView *editingTextView;
@property (nonatomic) BOOL keyboardShown;

- (void)startEditing;
- (void)endEditing;

@property (nonatomic, readonly) BOOL isNoteCellShowing;

@end
