#import "SettingsViewController.h"
#import "SettingsCell.h"
#import "CTXDOTableHeaderView.h"
#import "FacebookServices.h"
#import <Parse/Parse.h>
#import "PFUser+CTXDO.h"

@interface SettingsViewController ()

- (void)setupFBButton;
- (CGFloat)alertsDistancKmToSliderValue:(CGFloat)value;
- (CGFloat)sliderValueToAlertsDistancKm:(CGFloat)value;

@end

@implementation SettingsViewController

@synthesize settingsDataSource = _settingsDataSource;
@synthesize lastSliderValue = _lastSliderValue;
@synthesize settingsSliderView = _settingsSliderView;
@synthesize fbButton = _fbButton;;

#pragma mark -
#pragma mark Initialisation

- (void)viewDidLoad 
{	
    [super viewDidLoad];
	
	self.title = @"Settings";
	
	self.lastSliderValue = -1.0;
	
	[self setupFBButton];
}

- (void)viewDidUnload
{
	self.fbButton = nil;
}

#pragma mark -
#pragma mark Setup

- (void)setupDataSource
{
	[super setupDataSource];
	
	NSArray *section1 = [NSArray arrayWithObjects:@"", nil];
	NSArray *choicesList = [NSArray arrayWithObjects:section1, nil];
	
	self.settingsDataSource = [[[SettingsDataSource alloc]initWitChoicesList:choicesList]autorelease];
	self.tableView.backgroundColor = [DefaultStyleSheet sharedDefaultStyleSheet].darkBackgroundTexture;
	self.tableView.dataSource = self.settingsDataSource;
	[self.tableView reloadData];
}

- (BOOL)isFacebookConnected
{
	return ([[FacebookServices sharedFacebookServices].facebook isSessionValid]);
}

- (void)setupFBButton
{
	if (self.isFacebookConnected) {
		[self.fbButton setTitle:@"Logout Facebook" forState:UIControlStateNormal];
	} else {
		[self.fbButton setTitle:@"Facebook Connect" forState:UIControlStateNormal];
	}
	
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

- (SettingsSliderView *)settingsSliderView
{
	if (!_settingsSliderView) {
		_settingsSliderView = [[SettingsSliderView alloc]initWithFrame:CGRectZero];
		[_settingsSliderView.slider addTarget:self action:@selector(sliderDidChangeValue:) forControlEvents:UIControlEventValueChanged];
		_settingsSliderView.slider.minimumValue = 0.0;
		_settingsSliderView.slider.maximumValue = 4.0;
		CGFloat value = [PFUser currentUser].alertsDistanceWithin;
		self.settingsSliderView.slider.value = [self alertsDistancKmToSliderValue:value];
	}
	
	return _settingsSliderView;
	
	
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
	
	if (indexPath.section == 0) {
		CGFloat value = [PFUser currentUser].alertsDistanceWithin;
		self.settingsSliderView.slider.value = [self alertsDistancKmToSliderValue:value];
		self.settingsSliderView.frame = cell.contentView.bounds;
		[cell addSubview:self.settingsSliderView];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0) {
		return 86.0;
	}
	
	return tableView.rowHeight;
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
    
	__unused NSString *choice  = [self.settingsDataSource choiceForIndexPath:indexPath];
	
	
	[tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

#pragma mark -
#pragma mark SocialServices

- (void)socialServicesFacebookNotification:(NSNotification *)notification
{
	DLog(@"socialServicesNotification: %@", [notification object]);
	
	[[NSNotificationCenter defaultCenter]removeObserver:self name:notification.name object:nil];
	
	NSDictionary *infoDict = [notification object];
	BOOL success = [[infoDict valueForKey:@"success"]boolValue];
	NSArray *permissions = [infoDict valueForKey:@"permissions"];
	[[FacebookServices sharedFacebookServices]setFacebookAuthorizedForPemissions:permissions remove:!success];
	[self setupFBButton];
}

#pragma mark -
#pragma mark Actions

- (void)sliderDidChangeValue:(id)sender
{
	CTXDoSlider *slider = (CTXDoSlider *)sender;
	CGFloat value = slider.value;
	CGFloat sliderValue = 0.0;
	if (value < 0.5) {
		sliderValue = 0.0;
	} else if (value < 1.5) {
		sliderValue = 1.0;
	} else if (value < 2.5) {
		sliderValue = 2.0;
	} else if (value < 3.5) {
		sliderValue = 3.0;
	} else {
		sliderValue = 4.0;
	}
	
	slider.value = sliderValue;
	self.lastSliderValue = value;
}

- (void)doneTouched
{
	if (self.lastSliderValue != -1.0) {
        CGFloat toKmValue = [self sliderValueToAlertsDistancKm:self.settingsSliderView.slider.value];
        [PFUser currentUser].alertsDistanceWithin = toKmValue;
        // don't really care if fail or not
        [[PFUser currentUser] saveInBackground];
	}
	
	[self dismissModalViewControllerAnimated:TRUE];
}

- (IBAction)shouldLogout
{
	[self dismissModalViewControllerAnimated:FALSE];
	[[AppDelegate sharedAppDelegate]logout:TRUE animated:FALSE];
}

- (IBAction)shouldFacebookConnect
{
	if (!self.isFacebookConnected) {
		[[FacebookServices sharedFacebookServices]authorizeForPermissions:[NSArray arrayWithObjects:@"offline_access", @"user_events", nil]];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socialServicesFacebookNotification:) name:FacebookNotification object:nil];
	} else {
		[[FacebookServices sharedFacebookServices].facebook logout:[FacebookServices sharedFacebookServices]];
	}
}

#pragma mark -
#pragma mark Utilities

- (CGFloat)alertsDistancKmToSliderValue:(CGFloat)value
{
	CGFloat sliderValue = 0.0;
	if (value < 0.25) {
		sliderValue = 0.0;
	} else if (value < 0.75) {
		sliderValue = 1.0;
	} else if (value < 2.0) {
		sliderValue = 2.0;
	} else if (value < 4.0) {
		sliderValue = 3.0;
	} else {
		sliderValue = 5.0;
	}
	return sliderValue;
}

- (CGFloat)sliderValueToAlertsDistancKm:(CGFloat)value
{
	CGFloat kmValue = 0.0;
	if (value < 0.5) {
		kmValue = 0.1;
	} else if (value < 1.5) {
		kmValue = 0.5;
	} else if (value < 2.5) {
		kmValue = 1.0;
	} else if (value < 3.5) {
		kmValue = 3.0;
	} else {
		kmValue = 5.0;
	}
	return kmValue;
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.fbButton = nil;
    self.settingsDataSource = nil;
	[_settingsSliderView release];
    _settingsSliderView = nil;
    
	[super dealloc];
}

@end
