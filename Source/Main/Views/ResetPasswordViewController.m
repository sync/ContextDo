#import "ResetPasswordViewController.h"

@interface ResetPasswordViewController (private)

- (void)shouldResetPassword;

@end

@implementation ResetPasswordViewController

@synthesize usernameTextField;

#pragma mark -
#pragma mark Setup

- (void)viewWillAppear:(BOOL)animated
{
	[self.navigationController setNavigationBarHidden:FALSE animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Reset Password";
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:UserDidResetPasswordNotification object:nil];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:UserDidResetPasswordNotification];
	
	[self startEditing];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	self.usernameTextField = nil;
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
	
	[[APIServices sharedAPIServices] resetPasswordWithUsername:self.usernameTextField.text];
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

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:UserDidResetPasswordNotification];
	
	[usernameTextField release];
	
	[super dealloc];
}

@end
