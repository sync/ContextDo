#import "TasksViewController.h"
#import "TasksCell.h"
#import "TaskContainerViewController.h"
#import "NSDate+Extensions.h"

@interface TasksViewController (private)

- (void)cancelSearch;
- (void)refreshTasks;
- (void)reloadTasks:(NSArray *)newTasks;

@end


@implementation TasksViewController

@synthesize tasksDataSource, tasks, group, searchBar, tasksSave, mainNavController, hasCachedData;

#pragma mark -
#pragma mark Initialisation

- (void)viewDidLoad 
{
	[super viewDidLoad];
	
	[self.searchBar setBackgroundImage:[DefaultStyleSheet sharedDefaultStyleSheet].navBarBackgroundImage
						   forBarStyle:UIBarStyleBlackOpaque];
	self.searchBar.keyboardAppearance = UIKeyboardAppearanceAlert;
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

- (BOOL)isNearTasks
{
	return [self.group.name isEqualToString:NearTasksPlacholder];
}

- (void)setupDataSource
{
	[super setupDataSource];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAllTasks) name:TaskDeleteNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAllTasks) name:TaskEditNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAllTasks) name:TaskAddNotification object:nil];	
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:TasksSearchDidLoadNotification object:nil];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:TasksSearchDidLoadNotification];
	
	if (self.isTodayTasks) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:TasksDueTodayDidLoadNotification object:nil];
		[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:TasksDueTodayDidLoadNotification];
	} else if (self.isNearTasks) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:TasksWithinDidLoadNotification object:nil];
		[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:TasksWithinDidLoadNotification];
	} else {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:TasksDidLoadNotification object:nil];
		[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:TasksDidLoadNotification];
	}
	
	self.tasksDataSource = [[[TasksDataSource alloc]init]autorelease];
	self.tableView.dataSource = self.tasksDataSource;
	self.tableView.backgroundColor = [DefaultStyleSheet sharedDefaultStyleSheet].darkBackgroundTexture;
	self.tableView.rowHeight = 88.0;
	[self refreshTasks];
}

#pragma mark -
#pragma mark Content reloading

- (void)shouldReloadContent:(NSNotification *)notification
{
	NSDictionary *dict = [notification object];
	
	NSArray *newTasks = [dict valueForKey:@"tasks"];	
	if (![notification.name isEqualToString:TasksSearchDidLoadNotification] && self.tasksSave) {
		self.tasksSave = newTasks;
		return;
	}
	[self reloadTasks:newTasks];
}

- (void)reloadTasks:(NSArray *)newTasks
{
	if ([newTasks isEqualToArray:self.tasks]) {
		return;
	}
	
	[self.tasksDataSource resetContent];
	
	self.tasks = newTasks;
	
	[self.tasksDataSource.content addObjectsFromArray:self.tasks];
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
	
	TaskContainerViewController *controller = [[[TaskContainerViewController alloc]initWithNibName:@"TaskContainerView" bundle:nil]autorelease];
	controller.hidesBottomBarWhenPushed = TRUE;
	controller.task = task;
	controller.tasks = self.tasks;
	[self.mainNavController pushViewController:controller animated:TRUE];
	
	[tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[super scrollViewDidScroll:scrollView];
	
	if (!scrollView.dragging || scrollView.decelerating) {
		return;
	}
	
	[self.searchBar resignFirstResponder];
	if ([self.searchBar respondsToSelector:@selector(cancelButton)]) {
		[[self.searchBar valueForKey:@"cancelButton"] setEnabled:TRUE];
	}
}

#pragma mark -
#pragma mark BaseLoadingViewCenter Delegate

- (void)baseLoadingViewCenterDidStartForKey:(NSString *)key
{
	if (!self.tasksSave && self.hasCachedData) {
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

#pragma mark -
#pragma mark Actions

- (void)refreshTasks
{
	if (!self.tasksSave) {
		NSArray *archivedContent = nil;
		if (self.isTodayTasks) {
			NSString *due = [[NSDate date] getUTCDateWithformat:@"yyyy-MM-dd"];
			archivedContent = [[APIServices sharedAPIServices].tasksDueTodayDict
							   valueForKeyPath:[NSString stringWithFormat:@"%@.content", due]];
			self.hasCachedData = (archivedContent != nil);
			[self reloadTasks:archivedContent];
			
			[[APIServices sharedAPIServices]refreshTasksDueToday];
		} else if (self.isNearTasks) {
			archivedContent = [APIServices sharedAPIServices].tasksWithin;
			self.hasCachedData = (archivedContent != nil);
			[self reloadTasks:archivedContent];
			
			CLLocationCoordinate2D coordinate = [AppDelegate sharedAppDelegate].currentLocation.coordinate;
			[[APIServices sharedAPIServices]refreshTasksWithLatitude:coordinate.latitude longitude:coordinate.longitude];
		} else {
			archivedContent = [[APIServices sharedAPIServices].tasksWithGroupIdDict 
							   valueForKeyPath:[NSString stringWithFormat:@"%@.content", self.group.groupId]];
			self.hasCachedData = (archivedContent != nil);
			[self reloadTasks:archivedContent];
			
			[[APIServices sharedAPIServices]refreshTasksWithGroupId:self.group.groupId];
		}
	} else {
		// search mode
		[[APIServices sharedAPIServices]refreshTasksWithQuery:self.searchString];
	}
}

- (void)refreshAllTasks
{
	// todo here
	
	if (self.isTodayTasks) {
		[[APIServices sharedAPIServices]refreshTasksDueToday];
	} else if (self.isNearTasks) {
		CLLocationCoordinate2D coordinate = [AppDelegate sharedAppDelegate].currentLocation.coordinate;
		[[APIServices sharedAPIServices]refreshTasksWithLatitude:coordinate.latitude longitude:coordinate.longitude];
	} else {
		[[APIServices sharedAPIServices]refreshTasksWithGroupId:self.group.groupId];
	}
	
	if (self.tasksSave) {
		// search mode
		[[APIServices sharedAPIServices]refreshTasksWithQuery:self.searchString];
	}
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)aSearchBar
{
	if (!aSearchBar.showsCancelButton) {
		self.tasksSave = self.tasks;
		self.tasks = nil;
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
	[self reloadTasks:self.tasksSave];
	self.tasksSave = nil;
}

#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[self.searchBar resignFirstResponder];
	self.searchString = searchText;
	
	[self refreshTasks];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate 

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{	
	[self refreshTasks];
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:TasksWithinDidLoadNotification];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:TasksDidLoadNotification];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:TasksDueTodayDidLoadNotification];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:TasksSearchDidLoadNotification];
	
	[tasksSave release];
	[searchBar release];
	[group release];
	[tasks release];
	[tasksDataSource release];
	
	[super dealloc];
}

@end
