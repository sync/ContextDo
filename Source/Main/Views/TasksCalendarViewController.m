#import "TasksCalendarViewController.h"

@implementation TasksCalendarViewController

@synthesize tasks, group, mainNavController;
@synthesize loadingView, noResultsView, tasksCalendarDataSource;

#pragma mark -
#pragma mark Initialisation

- (void)viewDidLoad 
{
	[super viewDidLoad];
	
	
	
}

- (void)viewDidUnload
{
	[super viewDidUnload];
}

#pragma mark -
#pragma mark Setup

- (BOOL)isTodayTasks
{
	return [self.group.name isEqualToString:TodaysTasksPlacholder];
}

- (NSString *)nowDue
{
	NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	// 2010-07-24
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];
	return [dateFormatter stringFromDate:[NSDate date]];
}

- (void)setupDataSource
{
	if (!self.isTodayTasks) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:TasksDidLoadNotification object:nil];
		[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:TasksDidLoadNotification];
	} else {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:TasksDueDidLoadNotification object:nil];
		[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:TasksDueDidLoadNotification];
	}
	
	self.tasksCalendarDataSource = [[[TasksCalendarDataSource alloc]init]autorelease];
	self.tableView.dataSource = self.tasksCalendarDataSource;
	self.tableView.backgroundView = [DefaultStyleSheet sharedDefaultStyleSheet].darkBackgroundTextureView;
	[self refreshTasks];
	
	[self refreshTasks];
}

#pragma mark -
#pragma mark Content reloading

- (void)shouldReloadContent:(NSNotification *)notification
{
	NSDictionary *dict = [notification object];
	
	NSArray *newTasks = [dict valueForKey:@"tasks"];
	self.tasks = newTasks;
	// todo refresh calendar
}

#pragma mark -
#pragma mark Actions

- (void)refreshTasks
{
	if (!self.isTodayTasks) {
		[[APIServices sharedAPIServices]refreshTasksWithGroupId:self.group.groupId page:1];
	} else {
		[[APIServices sharedAPIServices]refreshTasksWithDue:self.nowDue page:1];
	}
}

#pragma mark -
#pragma mark Calendar View

- (NSArray*)calendarMonthView:(TKCalendarMonthView*)monthView marksFromDate:(NSDate*)startDate toDate:(NSDate*)lastDate{
	return nil; // todo
}
- (void) calendarMonthView:(TKCalendarMonthView*)monthView didSelectDate:(NSDate*)date{
	
	// CHANGE THE DATE TO YOUR TIMEZONE
	TKDateInformation info = [date dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSDate *myTimeZoneDay = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone systemTimeZone]];
	
	DLog(@"Date Selected: %@",myTimeZoneDay);
	
	[self.tableView reloadData];
}
- (void) calendarMonthView:(TKCalendarMonthView*)mv monthDidChange:(NSDate*)d{
	[super calendarMonthView:mv monthDidChange:d];
	
	[self.tableView reloadData];
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
	self.loadingView.labelText = @"Loading";
}

- (void)baseLoadingViewCenterDidStopForKey:(NSString *)key
{
	[self.loadingView hide:TRUE];
}

- (void)baseLoadingViewCenterShowErrorMsg:(NSString *)errorMsg forKey:(NSString *)key;
{
	[self.loadingView hide:FALSE];
	
	if (!self.noResultsView) {
		self.noResultsView = [[[MBProgressHUD alloc] initWithView:self.view]autorelease];
		self.noResultsView.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]] autorelease];
		self.noResultsView.labelText = errorMsg;
		self.noResultsView.mode = MBProgressHUDModeCustomView;
		self.noResultsView.delegate = self;
		[self.view addSubview:self.noResultsView];
		[self.view bringSubviewToFront:self.noResultsView];
		[self.noResultsView show:TRUE];
		[self performSelector:@selector(baseLoadingViewCenterRemoveErrorMsgForKey:) withObject:key afterDelay:1.5];
	}
}

- (void)baseLoadingViewCenterShowErrorMsg:(NSString *)errorMsg details:(NSString *)details forKey:(NSString *)key
{
	[self.loadingView hide:FALSE];
	
	if (!self.noResultsView) {
		self.noResultsView = [[[MBProgressHUD alloc] initWithView:self.view]autorelease];
		self.noResultsView.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]] autorelease];
		self.noResultsView.labelText = errorMsg;
		self.noResultsView.detailsLabelText = details;
		self.noResultsView.mode = MBProgressHUDModeCustomView;
		self.noResultsView.delegate = self;
		[self.view addSubview:self.noResultsView];
		[self.view bringSubviewToFront:self.noResultsView];
		[self.noResultsView show:TRUE];
		[self performSelector:@selector(baseLoadingViewCenterRemoveErrorMsgForKey:) withObject:key afterDelay:1.5];
	}
}

- (void)baseLoadingViewCenterRemoveErrorMsgForKey:(NSString *)key
{
	[self.noResultsView hide:TRUE];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    if (hud == self.loadingView) {
		[self.loadingView removeFromSuperview];
		self.loadingView = nil;
	} else if (hud == self.noResultsView) {
		[self.noResultsView removeFromSuperview];
		self.noResultsView = nil;
	}
}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:TasksDidLoadNotification];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:TasksDueDidLoadNotification];
	
	[group release];
	[tasks release];
	[mainNavController release];
	
	[tasksCalendarDataSource release];
	
	noResultsView.delegate = nil;
	[noResultsView release];
	loadingView.delegate = nil;
	[loadingView release];
	
	[super dealloc];
}


@end
