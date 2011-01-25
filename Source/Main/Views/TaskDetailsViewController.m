#import "TaskDetailsViewController.h"


@implementation TaskDetailsViewController

@synthesize task, taskDetailsView;

#pragma mark -
#pragma mark Setup

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.view.backgroundColor = [DefaultStyleSheet sharedDefaultStyleSheet].taskDarkGrayColor;
	[self refreshTask];
}

- (void)refreshTask
{
	[self.taskDetailsView setTask:self.task];
}

#pragma mark -
#pragma mark Actions

- (IBAction)mailTouched
{
	// todo
}

- (IBAction)editTouched
{
	// todo
}

- (IBAction)deleteTouched
{
	// todo
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[taskDetailsView release];
	[task release];
	
	[super dealloc];
}

@end
