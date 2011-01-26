#import "SettingsViewController.h"
#import "SettingsCell.h"
#import "CTXDOTableHeaderView.h"

@interface SettingsViewController (private)

@end

@implementation SettingsViewController

@synthesize settingsDataSource, lastSliderValue, settingsSliderView;

#pragma mark -
#pragma mark Initialisation

- (void)viewDidLoad 
{
	self.title = @"Settings";
	
    [super viewDidLoad];
	
	self.lastSliderValue = -1.0;
}

#pragma mark -
#pragma mark Setup

- (void)setupDataSource
{
	[super setupDataSource];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:UserDidLoadNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:UserEditNotification object:nil];
	
	NSArray *section1 = [NSArray arrayWithObjects:@"", nil];
	NSArray *choicesList = [NSArray arrayWithObjects:section1, nil];
	
	self.settingsDataSource = [[[SettingsDataSource alloc]initWitChoicesList:choicesList]autorelease];
	self.tableView.backgroundView = [DefaultStyleSheet sharedDefaultStyleSheet].darkBackgroundTextureView;
	self.tableView.dataSource = self.settingsDataSource;
	[self.tableView reloadData];
}

- (void)refresh
{
	
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
	if (!settingsSliderView) {
		settingsSliderView = [[SettingsSliderView alloc]initWithFrame:CGRectZero];
		[settingsSliderView.slider addTarget:self action:@selector(sliderDidChangeValue:) forControlEvents:UIControlEventValueChanged];
		settingsSliderView.slider.minimumValue = 0.0;
		settingsSliderView.slider.maximumValue = 4.0;
		CGFloat value = [APIServices sharedAPIServices].alertsDistanceWithin.floatValue;
		self.settingsSliderView.slider.value = [[APIServices sharedAPIServices]alertsDistancKmToSliderValue:value];;
	}
	
	return settingsSliderView;
	
	
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
		CGFloat value = [APIServices sharedAPIServices].alertsDistanceWithin.floatValue;
		self.settingsSliderView.slider.value = [[APIServices sharedAPIServices]alertsDistancKmToSliderValue:value];;
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
#pragma mark Actions

- (void)sliderDidChangeValue:(id)sender
{
	CTXDoSlider *slider = (CTXDoSlider *)sender;
	CGFloat value = slider.value;
	CGFloat sliderValue = value;
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
		NSDictionary *settings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:self.lastSliderValue]
															 forKey:AlertsDistanceWithin];
		
		[APIServices sharedAPIServices].alertsDistanceWithin = [NSNumber numberWithFloat:self.lastSliderValue];
		User *user = [User userWithSettings:settings facebookAccessToken:nil]; // todo remember fb token and pass it there
		[[APIServices sharedAPIServices]updateUser:user];
	}
	
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
	[settingsSliderView release];
	[settingsDataSource release];
	
	[super dealloc];
}

@end
