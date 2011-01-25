#import "InfoViewController.h"
#import "TasksInfoCell.h"
#import "TaskContainerViewController.h"

@interface InfoViewController (private)

- (void)refreshTasks;

@end


@implementation InfoViewController

@synthesize tasksUpdatedDataSource, infoButton;

#pragma mark -
#pragma mark Initialisation

- (void)viewDidLoad 
{
	[super viewDidLoad];
	
	//self.view.backgroundColor = [DefaultStyleSheet sharedDefaultStyleSheet].blackedOutColor;
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	
}

#pragma mark -
#pragma mark Setup


- (void)setupDataSource
{
	[super setupDataSource];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTasks) name:TaskEditNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTasks) name:TaskAddNotification object:nil];
	// remove this todo
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:TasksWithinDidLoadNotification object:nil];
	// end remove
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:TasksUpdatedSinceDidLoadNotification object:nil];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:TasksUpdatedSinceDidLoadNotification];
	
	self.tasksUpdatedDataSource = [[[TasksUpdatedDataSource alloc]init]autorelease];
	self.tableView.dataSource = self.tasksUpdatedDataSource;
	self.tableView.backgroundColor = [UIColor clearColor];
	
}

- (void)refreshTasks
{
	[[APIServices sharedAPIServices]refreshTasksEdited];
}

#pragma mark -
#pragma mark Content reloading

- (void)shouldReloadContent:(NSNotification *)notification
{
	NSDictionary *dict = [notification object];
	
	[self.tasksUpdatedDataSource resetContent];
	
	NSArray *newTasks = [dict valueForKey:@"tasks"];
	if (newTasks.count) {
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
	[self.navigationController pushViewController:controller animated:TRUE];
	
	[tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:TasksUpdatedSinceDidLoadNotification];
	
	[infoButton release];
	[tasksUpdatedDataSource release];
	
	[super dealloc];
}

@end
