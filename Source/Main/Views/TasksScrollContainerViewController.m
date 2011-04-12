#import "TasksScrollContainerViewController.h"

@implementation TasksScrollContainerViewController

@synthesize scrollView, currentPage;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentPage = 0;
    
#define LeftRightDiff 12.0
#define PageWidth 255.0
#define PagesDiff 24.0
#define PageHeight 393.0
#define TopDiff 0.0
    
    self.scrollView.contentSize = CGSizeMake(2 * LeftRightDiff + 3 * PageWidth + 2 * PagesDiff, PageHeight);
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    self.scrollView.delaysContentTouches = NO;
    self.scrollView.clipsToBounds = NO;
    
    UIView *view1 = [[[UIView alloc]initWithFrame:CGRectMake(LeftRightDiff, TopDiff, PageWidth, PageHeight)]autorelease];
    view1.backgroundColor = [UIColor redColor];
    [self.scrollView addSubview:view1];
    
    UIView *view2 = [[[UIView alloc]initWithFrame:CGRectMake(view1.frame.origin.x + view1.frame.size.width + PagesDiff, TopDiff, PageWidth, PageHeight)]autorelease];
    view2.backgroundColor = [UIColor greenColor];
    [self.scrollView addSubview:view2];
    
    UIView *view3 = [[[UIView alloc]initWithFrame:CGRectMake(view2.frame.origin.x + view2.frame.size.width + PagesDiff, TopDiff, PageWidth, PageHeight)]autorelease];
    view3.backgroundColor = [UIColor yellowColor];
    [self.scrollView addSubview:view3];
}

- (void)viewDidUnload
{
    self.scrollView = nil;
    
    [super viewDidUnload];
}

- (void)scrollToRowAtIndex:(NSInteger)index animated:(BOOL)animated
{
	NSInteger itemIndex = index;
	
	NSInteger count = 3.0;
	
	if (itemIndex < 0 && itemIndex < count) {
		itemIndex = 0;
	}
	
	if (itemIndex > count - 1) {
		itemIndex = count - 1;
	}
	
	if (itemIndex >= 0) {
		// Remember which index we are targeting so we can ignore intermediates along the way
		[self.scrollView setContentOffset:CGPointMake(itemIndex * (PageWidth + PagesDiff), 0.0) animated:animated];
	}
}

#pragma mark - ScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (self.currentPage != self.pageIndex) {
        self.currentPage = self.pageIndex;
        NSLog(@"did scroll to page: %d", self.pageIndex);
    }
}

- (NSInteger)pageIndex
{
	// make sure it snaps to grid
	CGFloat itemWidth = PageWidth + PagesDiff;
	CGFloat itemLocation = (self.scrollView.contentOffset.x / itemWidth);
	
	NSInteger itemIndex =  round(itemLocation);
	
	NSInteger count = 3;
	
	if (itemIndex < 0 && itemIndex < count) {
		itemIndex = 0;
	}
	
	if (itemIndex > count - 1) {
		itemIndex = count - 1;
	}
    
    return itemIndex;
}

#pragma mark - Dealloc

- (void)dealloc
{
    [scrollView release];
    
    [super dealloc];
}

@end
