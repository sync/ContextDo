#import "TasksContainerViewController.h"

@interface TasksContainerViewController (private)

- (void)showList;
- (void)showMap;
- (void)showCalendar;

@end


@implementation TasksContainerViewController

@synthesize containerNavController, tasksViewController, group;

#pragma mark -
#pragma mark Setup

- (void)viewDidLoad
{
	self.title = self.group.name;
	
	[super viewDidLoad];
	
	self.containerNavController.view.frame = self.view.bounds;
	[self.view addSubview:self.containerNavController.view];
	
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
		self.tasksViewController.group = self.group;
	}
	
	return tasksViewController;
}

- (void)setupNavigationBar
{
	[super setupNavigationBar];
	
	self.navigationItem.leftBarButtonItem = [[DefaultStyleSheet sharedDefaultStyleSheet] backItemWithText:self.navigationController.navigationBar.topItem.title
																								   target:self.navigationController
																								 selector:@selector(customBackButtonTouched)];
	
	self.navigationItem.titleView = [[DefaultStyleSheet sharedDefaultStyleSheet] titleViewWithText:self.title];
}

- (void)setupToolbar
{	
	[self.navigationController setToolbarHidden:FALSE animated:FALSE];
	
	UIBarButtonItem *flexItem = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			  target:nil
																			  action:nil]autorelease];
	
	UISegmentedControl *segmentedControl = [[[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"List", 
																					  @"Map", 
																					  @"Calendar",
																					  nil]]autorelease];
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
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
	[self setToolbarItems:items animated:FALSE];
}

#pragma mark -
#pragma mark Actions

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
	// TODO
}

- (void)showCalendar
{
	// TODO
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	[group release];
	[tasksViewController release];
	[containerNavController release];
	
    [super dealloc];
}


@end
