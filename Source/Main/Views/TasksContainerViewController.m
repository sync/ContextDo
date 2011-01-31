#import "TasksContainerViewController.h"
#import "TaskEditViewController.h"
#import <TapkuLibrary/TapkuLibrary.h>

@interface TasksContainerViewController (private)

- (void)showList;
- (void)showMap;
- (void)showCalendar;
- (void)addTask;
- (void)reloadTasks:(NSArray *)newTasks;
- (void)refreshTasks;

@end


@implementation TasksContainerViewController

@synthesize containerNavController, tasksViewController, group, containerView, tasksMapViewController;
@synthesize tasksCalendarViewController, showCloseButton, tasks;

#pragma mark -
#pragma mark Setup

- (void)viewDidLoad
{
	self.title = self.group.name;
	
	[super viewDidLoad];
	
	self.containerNavController.navigationBarHidden = TRUE;
	self.containerNavController.toolbarHidden = TRUE;
	[self.containerView addSubview:self.containerNavController.view];
	self.containerNavController.view.frame = self.containerView.bounds;
	
	if (self.isTodayTasks) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:TasksDueTodayDidLoadNotification object:nil];
	} else if (self.isNearTasks) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:TasksWithinDidLoadNotification object:nil];
	} else {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:TasksDidLoadNotification object:nil];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTasks) name:TaskDeleteNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTasks) name:TaskEditNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTasks) name:TaskAddNotification object:nil];
	
	[self refreshTasks];
	[self showList];
}

- (void)viewDidUnload
{
	self.title = self.group.name;
	
	[super viewDidUnload];
	
	self.containerNavController = nil;
}

- (TasksViewController *)tasksViewController
{
	if (!tasksViewController) {
		tasksViewController = [[TasksViewController alloc]initWithNibName:@"TasksView" bundle:nil];
		tasksViewController.group = self.group;
		tasksViewController.mainNavController = self.navigationController;
	}
	
	return tasksViewController;
}

- (TasksMapViewController *)tasksMapViewController
{
	if (!tasksMapViewController) {
		tasksMapViewController = [[TasksMapViewController alloc]initWithNibName:@"TasksMapView" bundle:nil];
		tasksMapViewController.group = self.group;
		tasksMapViewController.mainNavController = self.navigationController;
	}
	
	return tasksMapViewController;
}

- (TasksCalendarViewController *)tasksCalendarViewController
{
	if (!tasksCalendarViewController) {
		tasksCalendarViewController = [[TasksCalendarViewController alloc]initWithNibName:nil bundle:nil];
		tasksCalendarViewController.group = self.group;
		tasksCalendarViewController.mainNavController = self.navigationController;
	}
	
	return tasksCalendarViewController;
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
	
		
	self.navigationItem.titleView = [[DefaultStyleSheet sharedDefaultStyleSheet] titleViewWithText:self.title];
}

- (void)setupToolbar
{	
	[super setupToolbar];
	
	[self.navigationController setToolbarHidden:FALSE animated:FALSE];
	
	UIBarButtonItem *flexItem = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			  target:nil
																			  action:nil]autorelease];
	
	UISegmentedControl *segmentedControl = [[[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"List", 
																					  @"Map", 
																					  @"Calendar",
																					  nil]]autorelease];
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.selectedSegmentIndex = 0;
	[segmentedControl addTarget:self action:@selector(segementControlChanged:) forControlEvents:UIControlEventValueChanged];
	UIBarButtonItem *segmentItem = [[[UIBarButtonItem alloc]initWithCustomView:segmentedControl]autorelease];
	
	
	UIBarButtonItem *addItem = [[DefaultStyleSheet sharedDefaultStyleSheet] buttonItemWithImageNamed:@"icon_add_off.png" 
																			   highlightedImageNamed:@"icon_add_touch.png"
																							  target:self 
																							selector:@selector(addTask)];
	
	
	NSArray *items = [NSArray arrayWithObjects:
					  flexItem,
					  segmentItem,
					  flexItem,
					  addItem,
					  nil];
	[self setToolbarItems:items animated:TRUE];
}

#pragma mark -
#pragma mark Content reloading

- (BOOL)isTodayTasks
{
	return [self.group.name isEqualToString:TodaysTasksPlacholder];
}

- (BOOL)isNearTasks
{
	return [self.group.name isEqualToString:NearTasksPlacholder];
}

- (void)shouldReloadContent:(NSNotification *)notification
{
	NSDictionary *dict = [notification object];
	
	NSArray *newTasks = [dict valueForKey:@"tasks"];
	[self reloadTasks:newTasks];
}

- (void)reloadTasks:(NSArray *)newTasks
{
	self.tasks = newTasks;
	
	if (self.tasksViewController.tasksSave == 0) {
		[self.tasksViewController reloadTasks:self.tasks];
	} else {
		self.tasksViewController.tasksSave = self.tasks;
	}
	if (self.tasksMapViewController.tasksSave == 0) {
		[self.tasksMapViewController reloadTasks:self.tasks];
	} else {
		self.tasksMapViewController.tasksSave = self.tasks;
	}
}

#pragma mark -
#pragma mark Actions

- (void)refreshTasks
{
	// little bit of a hax
	if (self.isTodayTasks) {
		[[APIServices sharedAPIServices]refreshTasksDueToday];
	} else if (self.isNearTasks) {
		CLLocationCoordinate2D coordinate = [AppDelegate sharedAppDelegate].currentLocation.coordinate;
		[[APIServices sharedAPIServices]refreshTasksWithLatitude:coordinate.latitude longitude:coordinate.longitude];
	} else {
		[[APIServices sharedAPIServices]refreshTasksWithGroupId:self.group.groupId];
	}
}

- (void)segementControlChanged:(id)sender
{
	UISegmentedControl* segCtl = (UISegmentedControl *)sender;
	
	if ([segCtl selectedSegmentIndex] == 0) {
		[self showList];
	} else if ([segCtl selectedSegmentIndex] == 1) {
		[self showMap];
	} else {
		[self showCalendar];
	}
}

- (void)showList
{
	[self.containerNavController setViewControllers:[NSArray arrayWithObject:self.tasksViewController]];
}

- (void)showMap
{
	[self.containerNavController setViewControllers:[NSArray arrayWithObject:self.tasksMapViewController]];
}

- (void)showCalendar
{
	[self.containerNavController setViewControllers:[NSArray arrayWithObject:self.tasksCalendarViewController]];
}

- (void)addTask
{
	TaskEditViewController *controller = [[[TaskEditViewController alloc]initWithNibName:@"TaskEditView" bundle:nil]autorelease];
	controller.group = self.group;
	CustomNavigationController *navController = [[DefaultStyleSheet sharedDefaultStyleSheet]customNavigationControllerWithRoot:controller];
	[self.navigationController presentModalViewController:navController animated:TRUE];
}

- (void)closeButtonTouched
{
	[self dismissModalViewControllerAnimated:TRUE];
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	[tasksCalendarViewController release];
	[containerView release];
	[group release];
	[tasksViewController release];
	[tasksMapViewController release];
	[containerNavController release];
	
    [super dealloc];
}


@end
