#import "SettingsViewController.h"
#import "SettingsCell.h"
#import "CTXDOTableHeaderView.h"

@interface SettingsViewController (private)

@end

@implementation SettingsViewController

@synthesize settingsDataSource;

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
	
	NSArray *section1 = [NSArray arrayWithObjects:@"", nil];
	NSArray *choicesList = [NSArray arrayWithObjects:section1, nil];
	
	self.settingsDataSource = [[[SettingsDataSource alloc]initWitChoicesList:choicesList]autorelease];
	self.tableView.backgroundView = [DefaultStyleSheet sharedDefaultStyleSheet].darkBackgroundTextureView;
	self.tableView.dataSource = self.settingsDataSource;
}

#pragma mark -
#pragma mark Setup

- (void)setupNavigationBar
{
	[super setupNavigationBar];
	
	self.navigationItem.rightBarButtonItem = [[DefaultStyleSheet sharedDefaultStyleSheet] doneNavBarButtonItemWithText:@"Done"
																												target:self
																											  selector:@selector(doneTouched)];
	
	self.navigationItem.titleView = [[DefaultStyleSheet sharedDefaultStyleSheet] titleViewWithText:self.title];
}

#pragma mark -
#pragma mark TableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([self isIndexPathSingleRow:indexPath]) {
		[(SettingsCell *)cell setCellPosition:CTXDOCellPositionSingle];
	} else if (indexPath.row == 0) {
		[(SettingsCell *)cell setCellPosition:CTXDOCellPositionTop];
	} else if ([self isIndexPathLastRow:indexPath]) {
		[(SettingsCell *)cell setCellPosition:CTXDOCellPositionBottom];
	} else {
		[(SettingsCell *)cell setCellPosition:CTXDOCellPositionMiddle];
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	CTXDOTableHeaderView *view = [[[CTXDOTableHeaderView alloc]initWithFrame:CGRectZero]autorelease];
	view.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
	view.textLabel.text = [self.settingsDataSource tableView:self.tableView
								   titleForHeaderInSection:section];
	return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 40.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSString *choice  = [self.settingsDataSource choiceForIndexPath:indexPath];
	
	if ([choice isEqualToString:@"Reset Password"]) {
		[[APIServices sharedAPIServices]resetPasswordWithUsername:[[NSUserDefaults standardUserDefaults]stringForKey:UsernameUserDefaults]];
	} else if ([choice isEqualToString:@"Logout"]) {
		[self shouldLogout];
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

#pragma mark -
#pragma mark Actions

- (void)doneTouched
{
	// todo
	[self dismissModalViewControllerAnimated:TRUE];
}

- (IBAction)shouldLogout
{
	[self dismissModalViewControllerAnimated:FALSE];
	[[AppDelegate sharedAppDelegate]logout:TRUE animated:FALSE];
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[settingsDataSource release];
	
	[super dealloc];
}

@end
