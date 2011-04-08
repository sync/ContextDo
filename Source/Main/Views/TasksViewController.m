#import "TasksViewController.h"
#import "TaskContainerViewController.h"
#import "NSDate+Extensions.h"

@interface TasksViewController ()

- (void)cancelSearch;
- (void)refreshTasks;
- (void)reloadTasks:(NSArray *)newTasks;

@end


@implementation TasksViewController

@synthesize tasksDataSource, tasks, searchBar, tasksSave, mainNavController;

#pragma mark -
#pragma mark Initialisation

- (void)viewDidLoad 
{
	[super viewDidLoad];
	
	self.searchBar.tintColor = [UIColor colorWithWhite:0.3 alpha:1.0];
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
	return FALSE; // todo
}

- (BOOL)isNearTasks
{
	return FALSE; // todo
}

- (void)setupDataSource
{
	[super setupDataSource];
	
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
	// recognise when entire graph or not
	NSArray *newTasks = [notification object];
	[self reloadTasks:newTasks];
}

- (void)reloadTasks:(NSArray *)newTasks
{
	[self.tasksDataSource resetContent];
	
	self.tasks = newTasks;
	
	if (self.tasks.count > 0) {
		[self.tasksDataSource.content addObjectsFromArray:self.tasks];
	}
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
	
//	[(TasksCell *)cell setCellContext:context];
//	
//	[[(TasksCell *)cell completedButton]addTarget:self action:@selector(completedButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
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
#pragma mark Actions

- (void)refreshTasks
{
	if (!self.tasksSave) {
		// todo
	} else {
		// search mode
		// todo
	}
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
	// save todo
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
	if (aSearchBar.text.length == 0 && aSearchBar.showsCancelButton) {
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
	[tasksSave release];
	[searchBar release];
	[tasks release];
	[tasksDataSource release];
	
	[super dealloc];
}

@end
