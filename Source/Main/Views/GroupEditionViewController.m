#import "GroupEditionViewController.h"

@interface GroupEditionViewController (private)

- (void)doneEditing;

@end

@implementation GroupEditionViewController

@synthesize interestLabel, interest, indexPath, delegate;

#pragma mark -
#pragma mark Initialisation

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = (self.interest) ? @"Edit Interest" : @"Add Interest";
	
	self.interestLabel.text = self.interest;
	[self.interestLabel becomeFirstResponder];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	self.interestLabel = nil;
}

- (void)setupNavigationBar
{
	[super setupNavigationBar];
	
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

- (void)doneEditing
{
	[self.navigationController popViewControllerAnimated:TRUE];
	[self.delegate profileEditionViewController:self doneEditingWithInterest:self.interestLabel.text forIndexPath:self.indexPath];
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[interest release];
	[indexPath release];
	[interestLabel release];
	
	[super dealloc];
}

@end
