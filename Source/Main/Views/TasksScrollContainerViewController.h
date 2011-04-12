#import <Foundation/Foundation.h>
#import "BaseViewController.h"

@interface TasksScrollContainerViewController : BaseViewController <UIScrollViewDelegate> {
    
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, readonly) NSInteger pageIndex;
@property (nonatomic) NSInteger currentPage;

- (void)scrollToRowAtIndex:(NSInteger)index animated:(BOOL)animated;

@end
