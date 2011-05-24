#import <Foundation/Foundation.h>
#import "BaseViewController.h"
#import "TagsViewController.h"
#import <EventKitUI/EventKitUI.h>

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

@property (nonatomic, readonly) TagsViewController *tagsViewController;
@property (nonatomic, readonly) BOOL isShowingTagsView;
@property (nonatomic, assign) UIView *blackedOutView;
@property (nonatomic, retain) IBOutlet UIButton *tagsButton;
- (IBAction)tagsButtonPressed;

@property (nonatomic, retain) IBOutlet CustomSearchBar *searchBar;
@property (nonatomic, readonly) BOOL isShowingSearchBar;

@end
