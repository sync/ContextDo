#import "TaskContainerViewController.h"

@interface TaskContainerViewController (private)

- (void)showDetails;
- (void)showDirections;
- (void)showReschedule;

@end


@implementation TaskContainerViewController

@synthesize containerNavController, tasks, task, segmentControl, containerView, taskScheduleViewController;
@synthesize taskDirectionsViewController, taskDetailsViewController, arrowsControl, showCloseButton;

#pragma mark -
#pragma mark Setup

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.segmentControl.segments = [NSArray arrayWithObjects:
									@"Details",
									@"Directions",
									@"Reschedule",
									nil];
	[self.segmentControl addTarget:self action:@selector(segementControlChanged:) forControlEvents:UIControlEventTouchUpInside];
	
	self.containerNavController.navigationBarHidden = TRUE;
	self.containerNavController.toolbarHidden = TRUE;
	[self.containerView addSubview:self.containerNavController.view];
	self.containerNavController.view.frame = self.containerView.bounds;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskEditNotification:) name:TaskEditNotification object:nil];
	
	[self refreshTask];
	
	[self showDetails];
}

- (void)taskEditNotification:(NSNotification *)notification
{
	Task *editedTasks = [notification object];
	if ([editedTasks.taskId isEqual:self.task.taskId]) {
		self.task = editedTasks;
		[self refreshTask];
	}
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	self.containerNavController = nil;
}

- (TaskScheduleViewController *)taskScheduleViewController
{
	if (!taskScheduleViewController) {
		taskScheduleViewController = [[TaskScheduleViewController alloc]initWithNibName:@"TaskScheduleView" bundle:nil];
		taskScheduleViewController.task = self.task;
		taskScheduleViewController.mainNavController = self.navigationController;
	}
	
	return taskScheduleViewController;
}

- (TaskDirectionsViewController *)taskDirectionsViewController
{
	if (!taskDirectionsViewController) {
		taskDirectionsViewController = [[TaskDirectionsViewController alloc]initWithNibName:@"TaskDirectionsView" bundle:nil];
		taskDirectionsViewController.task = self.task;
		taskDirectionsViewController.mainNavController = self.navigationController;
	}
	
	return taskDirectionsViewController;
}

- (TaskDetailsViewController *)taskDetailsViewController
{
	if (!taskDetailsViewController) {
		taskDetailsViewController = [[TaskDetailsViewController alloc]initWithNibName:@"TaskDetailsView" bundle:nil];
		taskDetailsViewController.task = self.task;
		taskDetailsViewController.mainNavController = self.navigationController;
	}
	
	return taskDetailsViewController;
}

- (void)setupNavigationBar
{
	[super setupNavigationBar];
	
	if (!self.showCloseButton) {
		self.navigationItem.leftBarButtonItem = [[DefaultStyleSheet sharedDefaultStyleSheet] backItemWithText:self.navigationController.navigationBar.topItem.title
																									   target:self.navigationController
																									 selector:@selector(customBackButtonTouched)];
	} else {
		self.navigationItem.leftBarButtonItem = [[DefaultStyleSheet sharedDefaultStyleSheet] navBarButtonItemWithText:@"Close"
																											   target:self
																											 selector:@selector(closeButtonTouched)];
		
	}
	
	self.arrowsControl = [CTXDONavigationArrowsControl navigationArrowsControl];
	[self.arrowsControl addBackTarget:self action:@selector(shouldGoBack) forControlEvents:UIControlEventTouchUpInside];
	[self.arrowsControl addNextTarget:self action:@selector(shouldGoNext) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *rightItem = [[[UIBarButtonItem alloc]initWithCustomView:self.arrowsControl]autorelease];
	rightItem.width = self.arrowsControl.frame.size.width;
	self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)refreshTask
{
	self.title = self.task.name;
	self.navigationItem.titleView = [[DefaultStyleSheet sharedDefaultStyleSheet] titleViewWithText:self.title];
	
	NSInteger index = [self.tasks indexOfObject:self.task];
	self.arrowsControl.canGoBack = (index > 0);
	self.arrowsControl.canGoNext = (index < self.tasks.count - 1);
	
	if (taskDetailsViewController) {
		self.taskDetailsViewController.task = self.task;
		[self.taskDetailsViewController refreshTask];
	}
	if (taskDirectionsViewController) {
		self.taskDirectionsViewController.task = self.task;
		[self.taskDirectionsViewController refreshTask];
	}
	if (taskScheduleViewController) {
		self.taskScheduleViewController.task = self.task;
		[self.taskScheduleViewController refreshTask];
	}
}

#pragma mark -
#pragma mark Actions

- (void)shouldGoBack
{
	NSInteger index = [self.tasks indexOfObject:self.task];
	if (index == 0) {
		return;
	}
	Task *newTask = [self.tasks objectAtIndex:index - 1];
	self.task = newTask;
	[self refreshTask];
}

- (void)shouldGoNext
{
	NSInteger index = [self.tasks indexOfObject:self.task];
	if (index + 1 > self.tasks.count) {
		return;
	}
	Task *newTask = [self.tasks objectAtIndex:index + 1];
	self.task = newTask;
	[self refreshTask];
}

- (void)segementControlChanged:(id)sender
{
	UISegmentedControl* segCtl = (UISegmentedControl *)sender;
	
	if ([segCtl selectedSegmentIndex] == 0) {
		[self showDetails];
		[self.taskScheduleViewController updateTask];
	} else if ([segCtl selectedSegmentIndex] == 1) {
		[self showDirections];
		[self.taskScheduleViewController updateTask];
	} else {
		[self showReschedule];
	}
}

- (void)showDetails
{
	[self.containerNavController setViewControllers:[NSArray arrayWithObject:self.taskDetailsViewController]];
}

- (void)showDirections
{
	[self.containerNavController setViewControllers:[NSArray arrayWithObject:self.taskDirectionsViewController]];
}

- (void)showReschedule
{
	[self.containerNavController setViewControllers:[NSArray arrayWithObject:self.taskScheduleViewController]];
}

- (void)closeButtonTouched
{
	[self dismissModalViewControllerAnimated:TRUE];
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc 
{
	[arrowsControl release];
	[taskDetailsViewController release];
	[taskDirectionsViewController release];
	[taskScheduleViewController release];
	[containerView release];
	[segmentControl release];
	[tasks release];
	[containerNavController release];
	
    [super dealloc];
}

@end
