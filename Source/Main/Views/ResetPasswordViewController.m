#import "ResetPasswordViewController.h"
#import <Parse/Parse.h>

@interface ResetPasswordViewController ()

@end

@implementation ResetPasswordViewController

@synthesize usernameTextField;

#pragma mark -
#pragma mark Setup

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	self.title = @"Reset Password";
	
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:UserDidResetPasswordNotification];
	
	[self startEditing];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	self.usernameTextField = nil;
}

- (void)setupNavigationBar
{
	[super setupNavigationBar];
	
	self.navigationItem.leftBarButtonItem = [[DefaultStyleSheet sharedDefaultStyleSheet] backItemWithText:@"Cancel"
																								   target:self.navigationController
																								 selector:@selector(customBackButtonTouched)];
	
	self.navigationItem.titleView = [[DefaultStyleSheet sharedDefaultStyleSheet] titleViewWithText:self.title];
}

#pragma mark -
#pragma mark Content reloading

- (void)shouldReloadContent:(NSNotification *)notification
{
	[self.navigationController popViewControllerAnimated:TRUE];
}

#pragma mark -
#pragma mark Actions

- (IBAction)shouldResetPassword;
{
	[self endEditing];
    
    [PFUser requestPasswordResetForEmailInBackground:self.usernameTextField.text];
}

#pragma mark -
#pragma mark Editing

- (void)startEditing
{
	[self.usernameTextField becomeFirstResponder];
}

- (BOOL)shouldReturn
{
	return self.usernameTextField.text.length > 0;
}

- (void)endEditing
{
	[self.usernameTextField resignFirstResponder];
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[(CTXDODarkTextField *)textField updateBackgroundImage];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	[(CTXDODarkTextField *)textField updateBackgroundImage];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if ([self shouldReturn]) {
		[self shouldResetPassword];
	}
	return YES;
}

#pragma mark -
#pragma mark BaseLoadingViewCenter Delegate

- (void)baseLoadingViewCenterDidStartForKey:(NSString *)key
{
	[self.noResultsView hide:FALSE];
	
	if (!self.loadingView) {
		self.loadingView = [[[MBProgressHUD alloc] initWithView:self.view]autorelease];
		self.loadingView.delegate = self;
		[self.view addSubview:self.loadingView];
		[self.view bringSubviewToFront:self.loadingView];
		[self.loadingView show:TRUE];
	}
	self.loadingView.labelText = @"Reset Password";
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc 
{
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:UserDidResetPasswordNotification];
	
	[usernameTextField release];
	
	[super dealloc];
}

@end
