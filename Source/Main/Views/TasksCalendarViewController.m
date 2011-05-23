#import "TasksCalendarViewController.h"
#import "NSDate-Utilities.h"
#import "TaskContainerViewController.h"
#import "NSDate+Extensions.h"
#import "TasksCalendarCell.h"

@interface TasksCalendarViewController ()

- (NSArray *)filteredTasksForDate:(NSDate *)date;
- (void)reloadTasks:(NSArray *)newTasks;

@end


@implementation TasksCalendarViewController

@synthesize tasks, mainNavController;
@synthesize tasksCalendarDataSource;

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
	return FALSE; // todo
}

- (BOOL)isNearTasks
{
	return FALSE; // todo
}

- (void)setupDataSource
{	
	self.tasksCalendarDataSource = [[[TasksCalendarDataSource alloc]init]autorelease];
	self.tableView.dataSource = self.tasksCalendarDataSource;
	self.tableView.delegate = self;
	self.tableView.separatorColor = [UIColor clearColor];
	[self refreshTasks];
}

- (void)refreshTasks
{
	// todo refresh
    [self.monthView.monthDate getUTCDateWithformat:@"yyyy-MM"];
}

#pragma mark -
#pragma mark Content reloading

- (void)shouldReloadContent:(NSNotification *)notification
{
	NSArray *newTasks = [notification object];
	[self reloadTasks:newTasks];
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
#pragma mark Dealloc

- (void)dealloc
{	
	[tasks release];
	
	[tasksCalendarDataSource release];
	
	[super dealloc];
}


@end
