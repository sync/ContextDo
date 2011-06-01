#import "TaskScheduleViewController.h"

@interface TaskScheduleViewController ()



@end


@implementation TaskScheduleViewController

@synthesize mainNavController, userEdited;

#pragma mark -
#pragma mark Setup

- (void)updateTask
{
	if (self.userEdited ) {
		// save todo
		self.userEdited = FALSE;
	} else if (self.datePicker) {
		BOOL shouldRefresh = FALSE;
		if (self.onOffSwitch.on && ![self.task.dueAt isEqual:self.datePicker.date]) {
			self.task.dueAt = self.datePicker.date;
			shouldRefresh = TRUE;
		} else if (!self.onOffSwitch.on && self.task.dueAt) {
			self.task.dueAt = nil;
			shouldRefresh = TRUE;
		}
		if (shouldRefresh) {
			// save todo
		}
	}
}

- (void)viewDidLoad
{
	[super viewDidLoad];
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
	self.tableView.allowsSelection = FALSE;
	[self.taskDatePickerDataSource.content addObject:@"Show Due Time"];
	self.tableView.sectionHeaderHeight = 80.0;
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Actions

- (void)switchValueChanged:(id)sender
{
	UISwitch *aOnOffSwitch = (UISwitch *)sender;
	if (aOnOffSwitch.on) {
		self.task.dueAt = [self.datePicker date];
	} else {
		self.task.dueAt = nil;
	}
	self.userEdited = TRUE;
}

- (void)dealloc
{
	[self updateTask];
	
	[super dealloc];
}

@end
