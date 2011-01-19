#import "SettingsViewController.h"

@interface SettingsViewController (private)

- (void)shouldLogout;

@end

@implementation SettingsViewController

@synthesize choicesListDataSource;

#pragma mark -
#pragma mark Initialisation

- (void)viewDidLoad 
{
	self.title = @"Settings";
	
    [super viewDidLoad];
}

#pragma mark -
#pragma mark Setup

- (void)setupDataSource
{
	[super setupDataSource];
	
	NSArray *section1 = [NSArray arrayWithObjects:@"Reset Password", nil];
	NSArray *section2 = [NSArray arrayWithObjects:@"Logout", nil];
	NSArray *choicesList = [NSArray arrayWithObjects:section1, section2, nil];
	
	self.choicesListDataSource = [[[ChoicesListDataSource alloc]initWitChoicesList:choicesList]autorelease];
	self.tableView.dataSource = self.choicesListDataSource;
}

#pragma mark -
#pragma mark TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSString *choice  = [self.choicesListDataSource choiceForIndexPath:indexPath];
	
	if ([choice isEqualToString:@"Reset Password"]) {
		[[APIServices sharedAPIServices]resetPasswordWithUsername:[[NSUserDefaults standardUserDefaults]stringForKey:UsernameUserDefaults]];
	} else if ([choice isEqualToString:@"Logout"]) {
		[self shouldLogout];
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

#pragma mark -
#pragma mark Actions

- (void)shouldLogout
{
	// clear apiKey
	[APIServices sharedAPIServices].apiToken = nil;
	// clear username / password
	[APIServices sharedAPIServices].username = nil;
	[APIServices sharedAPIServices].password = nil;
	// clear all sessions + cookies
	[ASIHTTPRequest clearSession];
	// go back to user login
	[[AppDelegate sharedAppDelegate]showLoginView:FALSE];
	// Reset all views
	[self.navigationController popToRootViewControllerAnimated:FALSE];
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[choicesListDataSource release];
	
	[super dealloc];
}

@end
