#import "TasksViewController.h"

@interface TasksViewController (private)

- (void)reloadTasks:(NSArray *)newTasks removeCache:(BOOL)removeCache showMore:(BOOL)showMore;
- (void)refreshTasks;

@end


@implementation TasksViewController

@synthesize tasksDataSource, tasks, page, group;

#pragma mark -
#pragma mark Initialisation

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = self.group.name;
	
	self.page = 1;
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
	[super setupDataSource];
	
	if (!self.isTodayTasks) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:TasksDidLoadNotification object:nil];
		[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:TasksDidLoadNotification];
	} else {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:TasksDueDidLoadNotification object:nil];
		[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:TasksDueDidLoadNotification];
	}
	
	self.tasksDataSource = [[[TasksDataSource alloc]init]autorelease];
	self.tableView.dataSource = self.tasksDataSource;
	[self refreshTasks];
}

#pragma mark -
#pragma mark Content reloading

- (void)shouldReloadContent:(NSNotification *)notification
{
	NSDictionary *dict = [notification object];
	
	NSNumber *currentPage = [dict valueForKey:@"object"];
	self.page = currentPage.integerValue;
	
	NSArray *newTasks = [dict valueForKey:@"tasks"];
	[self reloadTasks:newTasks removeCache:(self.page == 1) showMore:newTasks.count == 10];
	
	[self hideRefreshHeaderView];
}

- (NSMutableArray *)tasks
{
	if (!tasks) {
		tasks = [[NSMutableArray alloc]init];
	}
	
	return tasks;
}

#define ShowMorePlaceholder @"Load More Groups..."

- (void)reloadTasks:(NSArray *)newTasks removeCache:(BOOL)removeCache showMore:(BOOL)showMore
{
	[self.tasksDataSource resetContent];
	
	if (removeCache) {
		[self.tasks removeAllObjects];
	}
	
	if (newTasks) {
		[self.tasks addObjectsFromArray:newTasks];
	}
	
	[self.tasksDataSource.content addObjectsFromArray:self.tasks];
	
	
	if (showMore) {
		Task *showMore = [Task taskWithId:[NSNumber numberWithInt:NSNotFound] 
									title: ShowMorePlaceholder
								 location:nil 
							   modifiedAt:nil];
		[self.tasksDataSource.content addObject:showMore];
	}
	
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	Task *task  = [self.tasksDataSource taskForIndexPath:indexPath];
	
	if (task.taskId.integerValue != NSNotFound) {
		
	} else {
		if ([task.name isEqualToString:ShowMorePlaceholder]) {
			self.page += 1;
			if (!self.isTodayTasks) {
				[[APIServices sharedAPIServices]refreshTasksWithGroupId:self.group.groupId page:self.page];
			} else {
				[[APIServices sharedAPIServices]refreshTasksWithDue:self.nowDue page:self.page];
			}
		}
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

- (void)showRefreshHeaderView
{
	[super showRefreshHeaderView];
	
	[self refreshTasks];
}

#pragma mark -
#pragma mark Actions

- (void)refreshTasks
{
	self.page = 1;
	
	if (!self.isTodayTasks) {
		[[APIServices sharedAPIServices]refreshTasksWithGroupId:self.group.groupId page:self.page];
	} else {
		[[APIServices sharedAPIServices]refreshTasksWithDue:self.nowDue page:self.page];
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
	[tasksDataSource release];
	
	[super dealloc];
}

@end
