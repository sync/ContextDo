#import "TaskContainerViewController.h"

@interface TaskContainerViewController (private)

- (void)showDetails;
- (void)showDirections;
- (void)showReschedule;

@end


@implementation TaskContainerViewController

@synthesize containerNavController, tasks, task, segmentControl, containerView, taskScheduleViewController;
@synthesize taskDirectionsViewController;

#pragma mark -
#pragma mark Setup

- (void)viewDidLoad
{
	self.title = self.task.name;
	
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
	
	[self showDetails];
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
	}
	
	return taskScheduleViewController;
}

- (TaskDirectionsViewController *)taskDirectionsViewController
{
	if (!taskDirectionsViewController) {
		taskDirectionsViewController = [[TaskDirectionsViewController alloc]initWithNibName:@"TaskDirectionsView" bundle:nil];
		taskDirectionsViewController.task = self.task;
	}
	
	return taskDirectionsViewController;
}

- (void)setupNavigationBar
{
	[super setupNavigationBar];
	
	self.navigationItem.leftBarButtonItem = [[DefaultStyleSheet sharedDefaultStyleSheet] backItemWithText:self.navigationController.navigationBar.topItem.title
																								   target:self.navigationController
																								 selector:@selector(customBackButtonTouched)];
	
	self.navigationItem.titleView = [[DefaultStyleSheet sharedDefaultStyleSheet] titleViewWithText:self.title];
	
	// todo previous / next button
}

#pragma mark -
#pragma mark Actions

- (void)segementControlChanged:(id)sender
{
	UISegmentedControl* segCtl = (UISegmentedControl *)sender;
	
	if ([segCtl selectedSegmentIndex] == 0) {
		[self showDetails];
	} else if ([segCtl selectedSegmentIndex] == 1) {
		[self showDirections];
	} else {
		[self showReschedule];
	}
}

- (void)showDetails
{
	// TODO
}

- (void)showDirections
{
	[self.containerNavController setViewControllers:[NSArray arrayWithObject:self.taskDirectionsViewController]];
}

- (void)showReschedule
{
	[self.containerNavController setViewControllers:[NSArray arrayWithObject:self.taskScheduleViewController]];
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc 
{
	[taskDirectionsViewController release];
	[taskScheduleViewController release];
	[containerView release];
	[segmentControl release];
	[tasks release];
	[containerNavController release];
	
    [super dealloc];
}

@end
