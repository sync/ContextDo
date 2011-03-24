#import "CustomNavigationController.h"


@implementation CustomNavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
	self = [[[[NSBundle mainBundle] loadNibNamed:@"CustomNavigationController" owner:self options:nil] lastObject]retain];
	if (self != nil) {
		[self setViewControllers:[NSArray arrayWithObject:rootViewController]];
	}
	return self;
}

@end
