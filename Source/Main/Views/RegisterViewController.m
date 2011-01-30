#import "RegisterViewController.h"

@implementation RegisterViewController

@synthesize usernameTextField, passwordTextField, passwordConfirmationTextField;

#pragma mark -
#pragma mark Setup

- (void)viewDidLoad 
{
	[super viewDidLoad];
	
	self.title = @"Register";
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:UserDidRegisterNotification object:nil];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:UserDidRegisterNotification];
	
	[self startEditing];
}

- (void)setupNavigationBar
{
	[super setupNavigationBar];
	
	self.navigationItem.rightBarButtonItem = [[DefaultStyleSheet sharedDefaultStyleSheet] doneNavBarButtonItemWithText:@"Done"
																												target:self
																											  selector:@selector(shouldRegister)];
	
	self.navigationItem.leftBarButtonItem = [[DefaultStyleSheet sharedDefaultStyleSheet] backItemWithText:@"Cancel"
																								   target:self.navigationController
																								 selector:@selector(customBackButtonTouched)];

	self.navigationItem.titleView = [[DefaultStyleSheet sharedDefaultStyleSheet] titleViewWithText:self.title];
}

#pragma mark -
#pragma mark Content reloading

- (void)shouldReloadContent:(NSNotification *)notification
{
	[[AppDelegate sharedAppDelegate]hideLoginView:TRUE];
}

#pragma mark -
#pragma mark Actions

- (IBAction)shouldRegister;
{
	[self endEditing];
	
	[[APIServices sharedAPIServices]registerWithUsername:self.usernameTextField.text
												password:self.passwordTextField.text];
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
		[self shouldRegister];
	} else {
		[self goNext];
	}
	return YES;
}

- (void)goNext
{
	if ([self.usernameTextField isFirstResponder]) {
		[self.passwordTextField becomeFirstResponder];
	} else if ([self.passwordTextField isFirstResponder]) {
		[self.passwordConfirmationTextField becomeFirstResponder];
	} else {
		[self.usernameTextField becomeFirstResponder];
	}
}

- (BOOL)shouldReturn
{
	return ([self.passwordConfirmationTextField isFirstResponder] && self.usernameTextField.text.length > 0 && self.passwordTextField.text.length > 0 &&
			self.passwordConfirmationTextField.text.length > 0);
}

- (void)endEditing
{
	[self.usernameTextField resignFirstResponder];
	[self.passwordTextField resignFirstResponder];
	[self.passwordConfirmationTextField resignFirstResponder];
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
	self.loadingView.labelText = @"Registering";
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:UserDidRegisterNotification];
	
	[passwordConfirmationTextField release];
	
	[super dealloc];
}

@end
