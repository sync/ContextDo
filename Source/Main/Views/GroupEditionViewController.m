#import "GroupEditionViewController.h"

@interface GroupEditionViewController (private)

- (void)doneEditing;
- (void)cancelEditing;

@end

@implementation GroupEditionViewController

@synthesize groupLabel, group;

#pragma mark -
#pragma mark Initialisation

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = (self.group) ? @"Edit Group" : @"Add Group";
	
	self.groupLabel.text = self.group.name;
	[self.groupLabel becomeFirstResponder];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	self.groupLabel = nil;
}

- (void)setupNavigationBar
{
	[super setupNavigationBar];
	
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																						   target:self
																						   action:@selector(cancelEditing)]autorelease];
	
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																						   target:self
																						   action:@selector(doneEditing)]autorelease];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField.text.length > 0) {
		[self doneEditing];
	}
	return YES;
}

#pragma mark -
#pragma mark Actions

- (void)cancelEditing
{
	[self.navigationController dismissModalViewControllerAnimated:TRUE];
}

- (void)doneEditing
{
	[self.navigationController dismissModalViewControllerAnimated:TRUE];
	// todo save
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[group release];
	[groupLabel release];
	
	[super dealloc];
}

@end
