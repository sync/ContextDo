#import "UINavigationController+Custom.h"


@implementation UINavigationController (CustomNavigationBar)

#pragma mark -
#pragma mark CustomNavigationBar

- (CustomNavigationBar *)customNavigationBar
{
	if (![self.navigationBar isKindOfClass:[CustomNavigationBar class]]) {
		return nil;
	}
	
	return (CustomNavigationBar *)self.navigationBar;
}

- (void)customBackButtonTouched
{
	[self popViewControllerAnimated:TRUE];
}

#pragma mark -
#pragma mark CustomToolbar

- (CustomToolbar *)customToolbar
{
	if (![self.toolbar isKindOfClass:[CustomToolbar class]]) {
		return nil;
	}
	
	return (CustomToolbar *)self.toolbar;
}

@end
