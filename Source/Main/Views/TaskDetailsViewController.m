#import "TaskDetailsViewController.h"


@implementation TaskDetailsViewController

@synthesize task, taskDetailsView, mainNavController;

#pragma mark -
#pragma mark Setup

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.view.backgroundColor = [DefaultStyleSheet sharedDefaultStyleSheet].taskDarkGrayColor;
	[self.taskDetailsView.completedButton addTarget:self action:@selector(completedButtonTouched:) forControlEvents:UIControlEventTouchUpInside];

	[self refreshTask];
}

- (void)refreshTask
{
	[self.taskDetailsView setTask:self.task];
}

#pragma mark -
#pragma mark Actions

- (void)completedButtonTouched:(id)sender
{
	if (self.task.completed) {
		self.task.completedAt = nil;
	} else {
		self.task.completedAt = [NSDate date];
	}
	
	[self refreshTask];
	
	[[APIServices sharedAPIServices]updateTask:self.task];
}

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
	[self.mainNavController popViewControllerAnimated:TRUE];
	[[APIServices sharedAPIServices]deleteTask:self.task];
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
