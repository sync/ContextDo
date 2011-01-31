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

//- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
//	[super scrollViewDidScroll:scrollView];
//	
//	[(TISwipeableTableView*)self.tableView hideVisibleBackView:NO];
//}
//
//- (TISwipeableTableView *)swipeableTableView
//{
//	if ([self.tableView isKindOfClass:[TISwipeableTableView class]]) {
//		return (TISwipeableTableView *)self.tableView;
//	}
//	
//	return nil;
//}
//
//static void completionCallback(SystemSoundID soundID, void * clientData) {
//	AudioServicesRemoveSystemSoundCompletion(soundID);
//}
//
//- (void)tableView:(UITableView *)tableView didSwipeCellAtIndexPath:(NSIndexPath *)indexPath {
//	
//	NSString * path = [[NSBundle mainBundle] pathForResource:@"tick" ofType:@"wav"];
//	NSURL * fileURL = [NSURL fileURLWithPath:path isDirectory:NO];
//	
//	SystemSoundID soundID;
//	AudioServicesCreateSystemSoundID((CFURLRef)fileURL, &soundID);
//	AudioServicesPlaySystemSound(soundID);
//	AudioServicesAddSystemSoundCompletion (soundID, NULL, NULL, completionCallback, NULL);
//}

@end
