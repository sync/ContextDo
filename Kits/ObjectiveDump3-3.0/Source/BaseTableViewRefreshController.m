#import "BaseTableViewRefreshController.h"


@implementation BaseTableViewRefreshController

@synthesize refreshHeaderView;

#pragma mark -
#pragma mark Setup

- (EGORefreshTableHeaderView *)refreshHeaderView
{
	if (!refreshHeaderView) {
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(00.0f, 
																						0.0f - self.tableView.bounds.size.height, 
																						self.view.frame.size.width, 
																						self.tableView.bounds.size.height)];
		refreshHeaderView.delegate = self;
		[self.tableView addSubview:refreshHeaderView];
		
		//  update the last update date
		[refreshHeaderView refreshLastUpdatedDate];
	}
	
	return refreshHeaderView;
}

#pragma mark -
#pragma mark Content reloading

- (void)hideRefreshHeaderView
{
	[self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

#pragma mark -
#pragma mark BaseLoadingViewCenter Delegate

- (void)baseLoadingViewCenterDidStopForKey:(NSString *)key
{
	[super baseLoadingViewCenterDidStopForKey:key];
	
	[self hideRefreshHeaderView];
}

#pragma mark -
#pragma mark UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{		
	[self.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[self.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate 

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{	
	// Refresh here
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{	
	return FALSE;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{	
	return [NSDate date]; // should return date data source was last changed
}

#pragma mark -
#pragma mark Memory managedment

- (void)viewDidUnload {
	[super viewDidUnload];
	
	[refreshHeaderView release];
	refreshHeaderView = nil;
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[refreshHeaderView release];
	
	[super dealloc];
}

@end
