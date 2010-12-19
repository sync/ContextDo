#import "RegisterViewController.h"

@implementation RegisterViewController

@synthesize usernameTextField, passwordTextField;

#pragma mark -
#pragma mark Setup

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Register";
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:UserDidRegisterNotification object:nil];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:UserDidRegisterNotification];
	
	[self startEditing];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if ([self shouldReturn]) {
		[self shouldRegister];
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
	self.loadingView.labelText = @"Registering";
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:UserDidRegisterNotification];
	
	[super dealloc];
}

@end
