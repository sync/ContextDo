#import "TasksContainerViewController.h"
#import <TapkuLibrary/TapkuLibrary.h>

@interface TasksContainerViewController ()

@end


@implementation TasksContainerViewController

@synthesize containerNavController, tasksViewController, containerView, tasksMapViewController;
@synthesize tasksCalendarViewController;

#pragma mark -
#pragma mark Setup

- (void)viewDidLoad
{	
	[super viewDidLoad];
	
	self.containerNavController.navigationBarHidden = TRUE;
	self.containerNavController.toolbarHidden = TRUE;
	[self.containerView addSubview:self.containerNavController.view];
	self.containerNavController.view.frame = self.containerView.bounds;
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	self.containerNavController = nil;
}

- (TasksViewController *)tasksViewController
{
	if (!tasksViewController) {
		tasksViewController = [[TasksViewController alloc]initWithNibName:@"TasksView" bundle:nil];
		tasksViewController.mainNavController = self.navigationController;
	}
	
	return tasksViewController;
}

- (TasksMapViewController *)tasksMapViewController
{
	if (!tasksMapViewController) {
		tasksMapViewController = [[TasksMapViewController alloc]initWithNibName:@"TasksMapView" bundle:nil];
		tasksMapViewController.mainNavController = self.navigationController;
	}
	
	return tasksMapViewController;
}

- (TasksCalendarViewController *)tasksCalendarViewController
{
	if (!tasksCalendarViewController) {
		tasksCalendarViewController = [[TasksCalendarViewController alloc]initWithNibName:nil bundle:nil];
		tasksCalendarViewController.mainNavController = self.navigationController;
	}
	
	return tasksCalendarViewController;
}

- (void)setupNavigationBar
{
	[super setupNavigationBar];
	
	self.navigationItem.leftBarButtonItem = [[DefaultStyleSheet sharedDefaultStyleSheet] 
                                             backItemWithText:self.navigationController.navigationBar.topItem.title
                                                        target:self.navigationController
                                                    selector:@selector(customBackButtonTouched)];
}

#pragma mark -
#pragma mark Actions

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

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	[tasksCalendarViewController release];
	[containerView release];
	[tasksViewController release];
	[tasksMapViewController release];
	[containerNavController release];
	
    [super dealloc];
}


@end
