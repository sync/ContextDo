#import "TasksCalendarViewController.h"
#import "NSDate-Utilities.h"
#import "TaskContainerViewController.h"
#import "NSDate+Extensions.h"
#import "TasksCalendarCell.h"

@interface TasksCalendarViewController (private)

- (NSArray *)filteredTasksForDate:(NSDate *)date;
- (void)reloadTasks:(NSArray *)newTasks;
- (void)restoreFromCached;

@end


@implementation TasksCalendarViewController

@synthesize tasks, group, mainNavController;
@synthesize loadingView, noResultsView, tasksCalendarDataSource, hasCachedData;

#pragma mark -
#pragma mark Initialisation

- (void)viewDidLoad 
{
	[super viewDidLoad];
	
	[self setupDataSource];
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

- (BOOL)isNearTasks
{
	return [self.group.name isEqualToString:NearTasksPlacholder];
}

- (void)setupDataSource
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreFromCached) name:TasksGraphDueDidLoadNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:TasksDueDidLoadNotification object:nil];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:TasksDueDidLoadNotification];
	
	self.tasksCalendarDataSource = [[[TasksCalendarDataSource alloc]init]autorelease];
	self.tableView.dataSource = self.tasksCalendarDataSource;
	self.tableView.backgroundColor = [DefaultStyleSheet sharedDefaultStyleSheet].darkBackgroundTexture;
	self.tableView.delegate = self;
	self.tableView.separatorColor = [UIColor clearColor];
	[self refreshTasks];
}

- (void)refreshTasks
{
	[self restoreFromCached];
	
	[[APIServices sharedAPIServices]refreshTasksWithDue:[self.monthView.monthDate getUTCDateWithformat:@"yyyy-MM"]];
}

#pragma mark -
#pragma mark Content reloading

- (void)shouldReloadContent:(NSNotification *)notification
{
	NSArray *newTasks = [notification object];
	[self reloadTasks:newTasks];
}

- (void)restoreFromCached
{
	NSArray *archivedContent = [[CacheServices sharedCacheServices].tasksWithDueDict 
								valueForKeyPath:[NSString stringWithFormat:@"%@.content", [self.monthView.monthDate getUTCDateWithformat:@"yyyy-MM"]]];
	self.hasCachedData = (archivedContent != nil);
	[self reloadTasks:archivedContent];
}

- (void)reloadTasks:(NSArray *)newTasks
{
	[self.tasksCalendarDataSource resetContent];
	
	self.tasks = newTasks;
	[self.monthView reload];
	
	NSArray *filteredTasks = [self filteredTasksForDate:[NSDate date]];
	if (filteredTasks.count > 0) {
		[self.tasksCalendarDataSource.content addObject:filteredTasks];
	}
	[self.tableView reloadData];
}

- (NSArray *)filteredTasksForDate:(NSDate *)date
{
	NSMutableArray *filterdEventsForDate = [NSMutableArray array];
	for (Task *task in self.tasks) {
		if ([date isSameDay:task.dueAt]) {
			[filterdEventsForDate addObject:task];
		}
	}
	
	return (filterdEventsForDate.count > 0) ? [NSArray arrayWithArray:filterdEventsForDate] : nil;
}

#pragma mark -
#pragma mark Calendar View

- (NSArray*)calendarMonthView:(TKCalendarMonthView*)monthView marksFromDate:(NSDate*)startDate toDate:(NSDate*)lastDate{
	NSArray *dueAtList = [self.tasks valueForKey:@"dueAt"];
	
	NSMutableArray *dataArray = [NSMutableArray array];
	
	NSDate *d = startDate;
	while(YES){
		BOOL found = FALSE;
		for (NSDate *dueAt in dueAtList) {
			if ([d isSameDay:dueAt]) {
				found = TRUE;
				break;
			}
		}
		[dataArray addObject:[NSNumber numberWithBool:found]];
		
		TKDateInformation info = [d dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		info.day++;
		d = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		if([d compare:lastDate]==NSOrderedDescending) break;
	}
	
	return dataArray;
	
}
- (void)calendarMonthView:(TKCalendarMonthView*)monthView didSelectDate:(NSDate*)date{
	
	[self.tasksCalendarDataSource resetContent];
	
	NSArray *filteredTasks = [self filteredTasksForDate:date];
	if (filteredTasks.count > 0) {
		[self.tasksCalendarDataSource.content addObject:filteredTasks];
	}
	[self.tableView reloadData];
}

- (void)calendarMonthView:(TKCalendarMonthView*)mv monthDidChange:(NSDate*)d{
	[self refreshTasks];
}

#pragma mark -
#pragma mark tableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	CTXDOCellContext context = CTXDOCellContextStandard;
	if (indexPath.row % 2 > 0) {
		context = CTXDOCellContextStandardAlternate;
	}
	
	[(TasksCalendarCell *)cell setCellContext:context];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	Task *task  = [self.tasksCalendarDataSource taskForIndexPath:indexPath];
	
	TaskContainerViewController *controller = [[[TaskContainerViewController alloc]initWithNibName:@"TaskContainerView" bundle:nil]autorelease];
	controller.hidesBottomBarWhenPushed = TRUE;
	controller.task = task;
	controller.tasks = self.tasks;
	[self.mainNavController pushViewController:controller animated:TRUE];
	
	[tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

#pragma mark -
#pragma mark BaseLoadingViewCenter Delegate

- (void)baseLoadingViewCenterDidStartForKey:(NSString *)key
{
	if (self.hasCachedData) {
		return;
	}
	
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
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:TasksDueDidLoadNotification];
	
	[group release];
	[tasks release];
	
	[tasksCalendarDataSource release];
	
	noResultsView.delegate = nil;
	[noResultsView release];
	loadingView.delegate = nil;
	[loadingView release];
	
	[super dealloc];
}


@end
