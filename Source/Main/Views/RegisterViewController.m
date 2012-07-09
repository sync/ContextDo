#import "RegisterViewController.h"
#import <Parse/Parse.h>

@implementation RegisterViewController

@synthesize usernameTextField, passwordTextField, passwordConfirmationTextField;

#pragma mark -
#pragma mark Setup

- (void)viewDidLoad 
{
	[super viewDidLoad];
	
	self.title = @"Register";
	
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
    
    NSString *notificationName = UserDidRegisterNotification;
    [[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStartLoadingForKey:notificationName];	
    
    PFUser *user = [PFUser user];
    user.username = self.usernameTextField.text;
    user.password = self.passwordTextField.text;
    user.email = self.usernameTextField.text;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [[APIServices sharedAPIServices] notifyDoneForKey:notificationName withObject:user];
            [self shouldReloadContent:nil];
        } else {
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            [[APIServices sharedAPIServices] notifyFailedForKey:notificationName withError:errorString];
        }
    }];
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
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:UserDidRegisterNotification];
	
	[passwordConfirmationTextField release];
	
	[super dealloc];
}

@end
