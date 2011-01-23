#import "TaskDetailsViewController.h"


@implementation TaskDetailsViewController

@synthesize task;

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.view.backgroundColor = [DefaultStyleSheet sharedDefaultStyleSheet].taskDarkGrayColor;
}

- (void)dealloc
{
	[task release];
	
	[super dealloc];
}

@end
