#import "BaseTableViewRefreshController.h"


@implementation BaseTableViewRefreshController

@synthesize refreshHeaderView;

#pragma mark -
#pragma mark Setup

- (EGORefreshTableHeaderView *)refreshHeaderView
{
	if (!refreshHeaderView) {
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 
																						 0.0f - self.tableView.bounds.size.height, 
																						 320.0f, 
																						 self.tableView.bounds.size.height)];
		refreshHeaderView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
		[self.tableView addSubview:refreshHeaderView];
		self.tableView.showsVerticalScrollIndicator = YES;
	}
	
	return refreshHeaderView;
}

#pragma mark -
#pragma mark Content reloading

- (void)showRefreshHeaderView
{
	[self.tableView reloadData];
	[self.refreshHeaderView setState:EGOOPullRefreshLoading];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.2];
	self.tableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
	[UIView commitAnimations];
}

- (void)hideRefreshHeaderView
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[self.tableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[self.refreshHeaderView setState:EGOOPullRefreshNormal];
	[self.refreshHeaderView setCurrentDate];  //  should check if data reload was successful 
}

#pragma mark -
#pragma mark BaseLoadingViewCenter Delegate

- (void)baseLoadingViewCenterDidStopForKey:(NSString *)key
{
	[super baseLoadingViewCenterDidStopForKey:key];
	
	[self hideRefreshHeaderView];
}

#pragma mark -
#pragma mark ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	if (scrollView.isDragging) {
		if (self.refreshHeaderView.state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f) {
			[self.refreshHeaderView setState:EGOOPullRefreshNormal];
		} else if (self.refreshHeaderView.state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -65.0f) {
			[self.refreshHeaderView setState:EGOOPullRefreshPulling];
		}
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	if (scrollView.contentOffset.y <= - 65.0f) {
		[self showRefreshHeaderView];
	}
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
