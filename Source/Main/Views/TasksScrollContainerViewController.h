#import <Foundation/Foundation.h>
#import "BaseViewController.h"
#import "TasksViewController.h"
#import "TasksMapViewController.h"
#import "TasksCalendarViewController.h"
#import "TITokenFieldView.h"

@interface TasksScrollContainerViewController : BaseViewController <UIScrollViewDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, EKEventEditViewDelegate> {
    
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, readonly) NSInteger pageIndex;
@property (nonatomic) NSInteger currentPage;

- (void)scrollToRowAtIndex:(NSInteger)index animated:(BOOL)animated;

@property (nonatomic, retain) UIImageView *chatBar;
@property (nonatomic, retain) UITextView *chatInput;
@property (nonatomic, assign) CGFloat previousContentHeight;
@property (nonatomic, retain) UIButton *createButton;

@property (nonatomic, readonly) TasksViewController *tasksViewController;
@property (nonatomic, readonly) TasksMapViewController *tasksMapViewController;
@property (nonatomic, readonly) TasksCalendarViewController *tasksCalendarViewController;

@property (nonatomic, retain) IBOutlet TITokenField *tokenField;

@property (nonatomic, retain) UITapGestureRecognizer *tapGesture;
@property (nonatomic, assign) BOOL keyboardShown;

@end
