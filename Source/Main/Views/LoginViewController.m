#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "ResetPasswordViewController.h"

@interface LoginViewController (private)

- (void)shouldLogin;
- (void)shouldRegister;

@end

@implementation LoginViewController

@synthesize usernameTextField, passwordTextField;

#pragma mark -
#pragma mark Setup

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Sign In";
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:UserDidLoginNotification object:nil];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:UserDidLoginNotification];
	
	[self startEditing];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	self.usernameTextField = nil;
	self.passwordTextField = nil;
}

- (void)setupNavigationBar
{
	[super setupNavigationBar];
	
	UIBarButtonItem *registerItem = [[[UIBarButtonItem alloc]initWithTitle:@"Register"
																	 style:UIBarButtonItemStyleBordered
																	target:self
																	action:@selector(shouldRegister)]autorelease];
	self.navigationItem.rightBarButtonItem = registerItem;
	
	UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.backBarButtonItem = backBarButtonItem;
	[backBarButtonItem release];
}

#pragma mark -
#pragma mark Content reloading

- (void)shouldReloadContent:(NSNotification *)notification
{
	[[AppDelegate sharedAppDelegate]hideLoginView:TRUE];
}

#pragma mark -
#pragma mark Actions

- (void)shouldLogin;
{
	[self endEditing];
	
	[[APIServices sharedAPIServices] loginWithUsername:self.usernameTextField.text
											  password:self.passwordTextField.text];
}

- (void)shouldRegister
{
	RegisterViewController *controller = [[[RegisterViewController alloc]initWithNibName:@"RegisterView"
																				  bundle:nil]autorelease];
	[self.navigationController pushViewController:controller animated:TRUE];
}

- (IBAction)shouldResetPassword
{
	ResetPasswordViewController *controller = [[[ResetPasswordViewController alloc]initWithNibName:@"ResetPasswordView"
																							bundle:nil]autorelease];
	[self.navigationController pushViewController:controller animated:TRUE];
}

#pragma mark -
#pragma mark Editing

- (void)startEditing
{
	[self goNext];
}

- (void)goNext
{
	if ([self.usernameTextField isFirstResponder]) {
		[self.passwordTextField becomeFirstResponder];
	} else {
		[self.usernameTextField becomeFirstResponder];
	}
}

- (BOOL)shouldReturn
{
	return ([self.passwordTextField isFirstResponder] && self.usernameTextField.text.length > 0 && self.passwordTextField.text.length > 0);
}

- (void)endEditing
{
	[self.usernameTextField resignFirstResponder];
	[self.passwordTextField resignFirstResponder];
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if ([self shouldReturn]) {
		[self shouldLogin];
	} else {
		[self goNext];
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
	self.loadingView.labelText = @"Sign In";
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:UserDidLoginNotification];
	
	[usernameTextField release];
	[passwordTextField release];
	
	[super dealloc];
}

@end
