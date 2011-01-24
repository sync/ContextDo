#import "TasksViewController.h"
#import "TasksCell.h"
#import "TaskContainerViewController.h"

@interface TasksViewController (private)

- (void)reloadTasks:(NSArray *)newTasks removeCache:(BOOL)removeCache showMore:(BOOL)showMore;
- (void)reloadSearchTasks:(NSArray *)newTasks;
- (void)cancelSearch;

@end


@implementation TasksViewController

@synthesize tasksDataSource, tasks, page, group, searchTasksDataSource, searchBar, pageSave, tasksSave, mainNavController;

#pragma mark -
#pragma mark Initialisation

- (void)viewDidLoad 
{
	[super viewDidLoad];
	
	self.page = 1;
	
	[self.searchBar setBackgroundImage:[DefaultStyleSheet sharedDefaultStyleSheet].navBarBackgroundImage
						   forBarStyle:UIBarStyleBlackOpaque];
	
	//[self.tableView setContentOffset:CGPointMake(0.0, self.searchBar.frame.size.height)];

}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	self.searchBar = nil;
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
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:TasksSearchDidLoadNotification object:nil];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:TasksSearchDidLoadNotification];
	
	if (!self.isTodayTasks) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:TasksDidLoadNotification object:nil];
		[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:TasksDidLoadNotification];
	} else {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:TasksDueDidLoadNotification object:nil];
		[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:TasksDueDidLoadNotification];
	}
	
	self.tasksDataSource = [[[TasksDataSource alloc]init]autorelease];
	self.tableView.dataSource = self.tasksDataSource;
	self.tableView.backgroundView = [DefaultStyleSheet sharedDefaultStyleSheet].darkBackgroundTextureView;
	self.tableView.rowHeight = 88.0;
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
	Task *task  = [self.tasksDataSource taskForIndexPath:indexPath];
	
	CTXDOCellContext context = CTXDOCellContextStandard;
	if (task.isClose) {
		context = CTXDOCellContextLocationAware;
	} else if (indexPath.row % 2 > 0) {
		context = CTXDOCellContextStandardAlternate;
	}
	
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
	
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
	[[APIServices sharedAPIServices]updateTask:task];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	TasksDataSource *dataSource = (TasksDataSource *)self.tableView.dataSource;
	Task *task  = [dataSource taskForIndexPath:indexPath];
	
	if (task.taskId.integerValue != NSNotFound) {
		TaskContainerViewController *controller = [[[TaskContainerViewController alloc]initWithNibName:@"TaskContainerView" bundle:nil]autorelease];
		controller.hidesBottomBarWhenPushed = TRUE;
		controller.task = task;
		controller.tasks = self.tasks;
		[self.mainNavController pushViewController:controller animated:TRUE];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (!scrollView.dragging || scrollView.decelerating) {
		return;
	}
	
	[self.searchBar resignFirstResponder];
	if ([self.searchBar respondsToSelector:@selector(cancelButton)]) {
		[[self.searchBar valueForKey:@"cancelButton"] setEnabled:TRUE];
	}
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
#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)aSearchBar
{
	if (!aSearchBar.showsCancelButton) {
		self.tasksSave = self.tasks;
		[self.tasks removeAllObjects];
	}
	
	[aSearchBar setShowsCancelButton:TRUE animated:TRUE];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar
{
	if (aSearchBar.text.length == 0) {
		[self cancelSearch];
	}
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar
{
	if ([aSearchBar.text isEqualToString:self.searchString]) {
		return;
	}
	[self filterContentForSearchText:aSearchBar.text scope:nil];
	
	if ([self.searchBar respondsToSelector:@selector(cancelButton)]) {
		[[self.searchBar valueForKey:@"cancelButton"] setEnabled:TRUE];
	}
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)aSearchBar
{
	[self cancelSearch];
}

- (void)cancelSearch
{
	[self.searchBar setShowsCancelButton:FALSE animated:TRUE];
	[self.searchBar resignFirstResponder];
	self.searchBar.text = nil;
	self.searchString = nil;
	self.page = self.pageSave;
	[self reloadTasks:self.tasksSave removeCache:TRUE showMore:FALSE]; // TODO
}

#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[self.searchBar resignFirstResponder];
	self.searchString = searchText;
	
	self.page = 1;
	[[APIServices sharedAPIServices]refreshTasksWithQuery:self.searchString page:self.page];
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:TasksDidLoadNotification];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:TasksDueDidLoadNotification];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:TasksSearchDidLoadNotification];
	
	[mainNavController release];
	[tasksSave release];
	[searchBar release];
	[group release];
	[tasks release];
	[tasksDataSource release];
	[searchTasksDataSource release];
	
	[super dealloc];
}

@end
