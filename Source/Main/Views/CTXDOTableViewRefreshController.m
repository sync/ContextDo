#import "CTXDOTableViewRefreshController.h"


@implementation CTXDOTableViewRefreshController

#pragma mark -
#pragma mark Setup

- (EGORefreshTableHeaderView *)refreshHeaderView
{
	if (!refreshHeaderView) {
		refreshHeaderView = [[CTXDORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 
																						0.0f - self.tableView.bounds.size.height + 1, 
																						self.view.frame.size.width, 
																						self.tableView.bounds.size.height)];
		refreshHeaderView.delegate = self;
		[self.tableView addSubview:refreshHeaderView];
		
		//  update the last update date
		[refreshHeaderView refreshLastUpdatedDate];
	}
	
	return refreshHeaderView;
}

@end
