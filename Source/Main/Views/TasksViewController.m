#import "TasksViewController.h"
#import "TaskContainerViewController.h"
#import "NSDate+Extensions.h"

@interface TasksViewController ()

- (void)refreshTasks;
- (void)reloadTasks:(NSArray *)newTasks;

@end


@implementation TasksViewController

@synthesize tasksDataSource, tasks, tasksSave, mainNavController;

#pragma mark -
#pragma mark Initialisation

- (void)viewDidLoad 
{
	[super viewDidLoad];
	
	NSMutableArray *todayTasks = [NSMutableArray arrayWithCapacity:2];
    NSDictionary * task1 = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"3pm", @"date",
                                 @"Tutorial", @"title",
                                 nil];
    [todayTasks addObject:task1];
    NSDictionary * task2 = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"5pm", @"date",
                            @"Lecture", @"title",
                            nil];
    [todayTasks addObject:task2];
    
    NSMutableArray *tomorrowTasks = [NSMutableArray arrayWithCapacity:2];
    NSDictionary * task3 = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"3pm", @"date",
                            @"Tutorial", @"title",
                            nil];
    [tomorrowTasks addObject:task3];
    NSDictionary * task4 = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"5pm", @"date",
                            @"Lecture", @"title",
                            nil];
    [tomorrowTasks addObject:task4];
    
    NSArray * newTasks = [NSArray arrayWithObjects:todayTasks, tomorrowTasks, nil];
    [self reloadTasks:newTasks];
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
	[super setupDataSource];
	
	self.tasksDataSource = [[[TasksDataSource alloc]init]autorelease];
	self.tableView.dataSource = self.tasksDataSource;
	//self.tableView.backgroundColor = [DefaultStyleSheet sharedDefaultStyleSheet].darkBackgroundTexture;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	TasksDataSource *dataSource = (TasksDataSource *)self.tableView.dataSource;
	NSDictionary *task  = [dataSource taskForIndexPath:indexPath];
    
    // todo
	
//	TaskContainerViewController *controller = [[[TaskContainerViewController alloc]initWithNibName:@"TaskContainerView" bundle:nil]autorelease];
//	controller.hidesBottomBarWhenPushed = TRUE;
//	controller.task = task;
//	controller.tasks = self.tasks;
//	[self.mainNavController pushViewController:controller animated:TRUE];
	
	[tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

#pragma mark -
#pragma mark Actions

- (void)refreshTasks
{
	if (!self.tasksSave) {
		// todo
//        Task *task = [Task taskWithName:@"Test Task" latitude:0.0 longitude:0.0];
//        self.tasks = [NSArray arrayWithObject:task];
	} else {
		// search mode
		// todo
	}
}

- (void)completedButtonTouched:(id)sender
{
	UIButton *button = (UIButton *)sender;
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.tasksDataSource rowForTag:button.tag]inSection:0];
	
	NSDictionary *task = [self.tasksDataSource taskForIndexPath:indexPath];
	
//	if (task.completed) {
//		task.completedAt = nil;
//	} else {
//		task.completedAt = [NSDate date];
//	}
	
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
	// save todo
}

#pragma mark -
#pragma mark Content Filtering

- (void)cancelSearch
{
    self.searchString = nil;
    [self reloadTasks:self.tasksSave];
    self.tasksSave = nil;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    self.searchString = searchText;
    
    [self refreshTasks];
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{	
	[tasksSave release];
	[tasks release];
	[tasksDataSource release];
	
	[super dealloc];
}

@end
