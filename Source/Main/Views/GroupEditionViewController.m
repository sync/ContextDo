#import "GroupEditionViewController.h"

@interface GroupEditionViewController (private)

- (void)doneEditing;
- (void)cancelEditing;

@end

@implementation GroupEditionViewController

@synthesize groupTextField, group;

#pragma mark -
#pragma mark Initialisation

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = (self.group) ? @"Edit Group" : @"Add Group";
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:GroupEditNotification object:nil];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:GroupEditNotification];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:GroupAddNotification object:nil];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:GroupAddNotification];
	
	self.groupTextField.text = self.group.name;
	[self.groupTextField becomeFirstResponder];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	self.groupTextField = nil;
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
	[self.groupTextField resignFirstResponder];
	if (self.group) {
		self.group.name = self.groupTextField.text;
		[[APIServices sharedAPIServices]editGroupWithId:self.group.groupId name:self.groupTextField.text];
	} else {
		[[APIServices sharedAPIServices]createGroupWithName:self.groupTextField.text];
	}
}

#pragma mark -
#pragma mark Content reloading

- (void)shouldReloadContent:(NSNotification *)notification
{
	[self.navigationController dismissModalViewControllerAnimated:TRUE];
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:GroupEditNotification];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:GroupAddNotification];
	
	[group release];
	[groupTextField release];
	
	[super dealloc];
}

@end
