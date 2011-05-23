#import <Foundation/Foundation.h>
#import "BaseViewController.h"
#import "TagsViewController.h"

@interface TasksScrollContainerViewController : BaseViewController <UIScrollViewDelegate, UITextViewDelegate, UIGestureRecognizerDelegate> {
    
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, readonly) NSInteger pageIndex;
@property (nonatomic) NSInteger currentPage;

- (void)scrollToRowAtIndex:(NSInteger)index animated:(BOOL)animated;

@property (nonatomic, retain) UIImageView *chatBar;
@property (nonatomic, retain) UITextView *chatInput;
@property (nonatomic, assign) CGFloat previousContentHeight;
@property (nonatomic, retain) UIButton *createButton;

@property (nonatomic, readonly) TagsViewController *tagsViewController;
@property (nonatomic, readonly) BOOL isShowingTagsView;
@property (nonatomic, assign) UIView *blackedOutView;
@property (nonatomic, retain) IBOutlet UIButton *tagsButton;
- (IBAction)tagsButtonPressed;

@end
