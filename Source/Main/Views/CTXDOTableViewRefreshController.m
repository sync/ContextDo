#import "CTXDOTableViewRefreshController.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation CTXDOTableViewRefreshController

#pragma mark -
#pragma mark Setup

- (EGORefreshTableHeaderView *)refreshHeaderView
{
	if (!refreshHeaderView) {
		refreshHeaderView = [[CTXDORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 
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

- (CGFloat)refreshHeaderOffset
{
	return self.refreshHeaderView.frame.origin.y - 0.0f - self.tableView.bounds.size.height;
}

- (void)setRefreshHeaderOffset:(CGFloat)offset
{
	CGRect rect = self.refreshHeaderView.frame;
	rect.origin.y = 0.0f - self.tableView.bounds.size.height + offset;
	self.refreshHeaderView.frame = CGRectIntegral(rect);
}

@end
