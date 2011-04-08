#import "InfoViewController.h"
#import "TasksInfoCell.h"
#import "TaskContainerViewController.h"
#import "NSDate+Extensions.h"

@interface InfoViewController ()

- (void)refreshTasks;
- (void)reloadTasks:(NSArray *)newTasks;

@end


@implementation InfoViewController

@synthesize tasksUpdatedDataSource, mainNavController;

#pragma mark -
#pragma mark Initialisation

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self refreshTasks];
}

#pragma mark -
#pragma mark Setup


- (void)setupDataSource
{
	[super setupDataSource];
	
	self.tasksUpdatedDataSource = [[[TasksUpdatedDataSource alloc]init]autorelease];
	self.tableView.dataSource = self.tasksUpdatedDataSource;
	self.tableView.backgroundColor = [UIColor clearColor];
}

- (void)refreshTasks
{
	// todo
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
	[self.tasksUpdatedDataSource resetContent];
	if (newTasks.count > 0) {
		[self.tasksUpdatedDataSource.content addObjectsFromArray:newTasks];
	}
	
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark TableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	CTXDOCellContext context = CTXDOCellContextUpatedTasksLight;
	
	if ([self isIndexPathSingleRow:indexPath]) {
		[(TasksInfoCell *)cell setCellPosition:CTXDOCellPositionSingle context:context];
	} else if (indexPath.row == 0) {
		[(TasksInfoCell *)cell setCellPosition:CTXDOCellPositionTop context:context];
	} else if ([self isIndexPathLastRow:indexPath]) {
		[(TasksInfoCell *)cell setCellPosition:CTXDOCellPositionBottom context:context];
	} else {
		[(TasksInfoCell *)cell setCellPosition:CTXDOCellPositionMiddle context:context];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	Task *task  = [self.tasksUpdatedDataSource taskForIndexPath:indexPath];;
	
	TaskContainerViewController *controller = [[[TaskContainerViewController alloc]initWithNibName:@"TaskContainerView" bundle:nil]autorelease];
	controller.hidesBottomBarWhenPushed = TRUE;
	controller.task = task;
	controller.tasks = self.tasksUpdatedDataSource.content;
	[self.mainNavController pushViewController:controller animated:TRUE];
	
	[tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[tasksUpdatedDataSource release];
	
	[super dealloc];
}

@end
