#import "TasksViewController.h"
#import "TasksCell.h"

@interface TasksViewController (private)

- (void)reloadTasks:(NSArray *)newTasks removeCache:(BOOL)removeCache showMore:(BOOL)showMore;
- (void)refreshTasks;
- (void)reloadSearchTasks:(NSArray *)newTasks;

@end


@implementation TasksViewController

@synthesize tasksDataSource, tasks, page, group, searchTasksDataSource;

#pragma mark -
#pragma mark Initialisation

- (void)viewDidLoad 
{
	[super viewDidLoad];
	
	self.page = 1;
	
	[self.searchDisplayController.customSearchBar setBackgroundImage:[DefaultStyleSheet sharedDefaultStyleSheet].navBarBackgroundImage
														 forBarStyle:UIBarStyleBlackOpaque];

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
	self.tableView.backgroundView = [DefaultStyleSheet sharedDefaultStyleSheet].backgroundTextureView;
	self.tableView.rowHeight = 88.0;
	[self refreshTasks];
}

- (void)setupSearchDataSource
{
	[super setupSearchDataSource];
	
	self.searchTasksDataSource = [[[TasksDataSource alloc]init]autorelease];
	self.searchDisplayController.searchResultsTableView.dataSource = self.searchTasksDataSource;
	self.searchDisplayController.searchResultsTableView.backgroundView = [DefaultStyleSheet sharedDefaultStyleSheet].backgroundTextureView;
	self.searchDisplayController.searchResultsTableView.rowHeight = 88.0;
	self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
	
	if (newTasks.count) {
		[self.tasks addObjectsFromArray:newTasks];
	}
	
	[self.tasksDataSource.content addObjectsFromArray:self.tasks];
	
	
	if (showMore) {
		Task *showMore = [Task taskWithId:[NSNumber numberWithInt:NSNotFound] 
									 name: ShowMorePlaceholder
								 location:nil];
		[self.tasksDataSource.content addObject:showMore];
	}
	
	[self.tableView reloadData];
}

- (void)reloadSearchTasks:(NSArray *)newTasks
{
	[self.searchTasksDataSource resetContent];
	
	[self.searchTasksDataSource.content addObjectsFromArray:newTasks];
	
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark TableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	__unused Task *task  = [self.tasksDataSource taskForIndexPath:indexPath];
	
	CTXDOCellContext context = CTXDOCellContextStandard;
	if (indexPath.row % 2 > 0) {
		context = CTXDOCellContextStandardAlternate;
	}
	
	// TODO location aware
	
	[(TasksCell *)cell setCellContext:context];
	
	[[(TasksCell *)cell completedButton]addTarget:self action:@selector(completedButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)completedButtonTouched:(id)sender
{
	UIButton *button = (UIButton *)sender;
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.tasksDataSource rowForTag:button.tag]inSection:0];
	
	Task *task = [self.tasksDataSource taskForIndexPath:indexPath];
	
	if (task.completed) {
		task.completedAt = nil;
	} else {
		task.completedAt = [NSDate date];
	}
	
	// TODO update task api
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	Task *task  = nil;
	if (self.searchDisplayController.active) {
		[self.tasksDataSource taskForIndexPath:indexPath];
	} else {
		[self.searchTasksDataSource taskForIndexPath:indexPath];
	}
	
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
#pragma mark Search

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	self.searchString = searchText;
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", self.searchString];
	NSArray *filteredTasks = [self.tasks filteredArrayUsingPredicate:predicate];
	[self reloadSearchTasks:filteredTasks];
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
	[searchTasksDataSource release];
	
	[super dealloc];
}

@end
