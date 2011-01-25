#import "TaskScheduleViewController.h"


@implementation TaskScheduleViewController

@synthesize mainNavController;

#pragma mark -
#pragma mark Setup

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.view.backgroundColor = [DefaultStyleSheet sharedDefaultStyleSheet].taskDarkGrayColor;
}

- (void)setupNavigationBar
{
	// Nothing
}

- (void)setupDataSource
{
	[super setupDataSource];
	
	self.taskDatePickerDataSource = [[[TaskDatePickerDataSource alloc]init]autorelease];
	self.taskDatePickerDataSource.tempTask = self.task;
	self.tableView.dataSource = self.taskDatePickerDataSource;
	self.tableView.backgroundColor = [DefaultStyleSheet sharedDefaultStyleSheet].taskDarkGrayColor;
	self.tableView.allowsSelection = FALSE;
	[self.taskDatePickerDataSource.content addObject:@"Show Due Time"];
	self.tableView.sectionHeaderHeight = 80.0;
	[self.tableView reloadData];
}

@end
