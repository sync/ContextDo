#import "TaskDetailsViewController.h"
#import "TaskEditViewController.h"

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
	if ([MFMailComposeViewController canSendMail]) {
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		picker.mailComposeDelegate = self;
		
		[picker setSubject:@"Check out this task!"];
		
		// Fill out the email body text
		NSString *emailBody = [NSString stringWithFormat:@"For now only task name: %@, ", self.task.name];
		
		[picker setMessageBody:emailBody isHTML:NO];
		
		[self.mainNavController presentModalViewController:picker animated:YES];
		[picker release];
	}
}

- (IBAction)editTouched
{
	TaskEditViewController *controller = [[[TaskEditViewController alloc]initWithNibName:@"TaskEditView" bundle:nil]autorelease];
	controller.task = self.task;
	CustomNavigationController *navController = [[[CustomNavigationController alloc]initWithRootViewController:controller]autorelease];
	[navController.customNavigationBar setBackgroundImage:[DefaultStyleSheet sharedDefaultStyleSheet].navBarBackgroundImage
											  forBarStyle:UIBarStyleDefault];
	[self.mainNavController presentModalViewController:navController animated:TRUE];
}

- (IBAction)deleteTouched
{
	[self.mainNavController popViewControllerAnimated:TRUE];
	[[APIServices sharedAPIServices]deleteTask:self.task];
}

#pragma mark -
#pragma mark MFMailComposeViewController Delegate

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	NSString *message = nil;
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			message = @"result: canceled";
			break;
		case MFMailComposeResultSaved:
			message = @"result: saved";
			break;
		case MFMailComposeResultSent:
			message = @"result: sent";
			break;
		case MFMailComposeResultFailed:
			message = @"result: failed";
			break;
		default:
			message = @"result: not sent";
			break;
	}
	// Display error
	DLog(@"%@", message);
	// Dismiss the modal view controller
	[[AppDelegate sharedAppDelegate].navigationController dismissModalViewControllerAnimated:YES];
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
