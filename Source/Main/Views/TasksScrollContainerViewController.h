#import <Foundation/Foundation.h>
#import "BaseViewController.h"

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

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, readonly) BOOL isShowingSearchBar;

@end
