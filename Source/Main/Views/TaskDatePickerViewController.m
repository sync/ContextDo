#import "TaskDatePickerViewController.h"
#import "TaskEditCell.h"

@interface TaskDatePickerViewController (private)

- (void)switchValueChanged:(id)sender;

@end


@implementation TaskDatePickerViewController

@synthesize task, datePicker, taskDatePickerDataSource, onOffSwitch;

#pragma mark -
#pragma mark Initialisation

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[self switchValueChanged:self.onOffSwitch];
}

- (void)viewDidLoad 
{
    self.title = @"Choose Time";
	
	[super viewDidLoad];
	
	[self.datePicker setDate:(self.task.dueAt) ? self.task.dueAt : [NSDate date] animated:FALSE];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	self.datePicker = nil;
}

#pragma mark -
#pragma mark Setup

- (void)setupNavigationBar
{
	[super setupNavigationBar];
	
	self.navigationItem.titleView = [[DefaultStyleSheet sharedDefaultStyleSheet] titleViewWithText:self.title];
	
	self.navigationItem.leftBarButtonItem = [[DefaultStyleSheet sharedDefaultStyleSheet] backItemWithText:@"Back"
																								   target:self.navigationController
																								 selector:@selector(customBackButtonTouched)];
	
}

- (void)setupDataSource
{
	[super setupDataSource];
	
	self.taskDatePickerDataSource = [[[TaskDatePickerDataSource alloc]init]autorelease];
	self.taskDatePickerDataSource.task = task;
	self.tableView.dataSource = self.taskDatePickerDataSource;
	self.tableView.backgroundColor = [DefaultStyleSheet sharedDefaultStyleSheet].backgroundTexture;
	self.tableView.allowsSelection = FALSE;
	[self.taskDatePickerDataSource.content addObject:@"Show Due Time"];
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark TableView Delegate

- (void)tableView:(UITableView *)aTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	CTXDOCellContext context = CTXDOCellContextTaskEditInput;
	
	if ([self isIndexPathSingleRow:indexPath]) {
		[(TaskEditCell *)cell setCellPosition:CTXDOCellPositionSingle context:context];
	} else if (indexPath.row == 0) {
		[(TaskEditCell *)cell setCellPosition:CTXDOCellPositionTop context:context];
	} else if ([self isIndexPathLastRow:indexPath]) {
		[(TaskEditCell *)cell setCellPosition:CTXDOCellPositionBottom context:context];
	} else {
		[(TaskEditCell *)cell setCellPosition:CTXDOCellPositionMiddle context:context];
	}
	
	self.onOffSwitch = [[[UISwitch alloc]initWithFrame:CGRectZero]autorelease];
	[self.onOffSwitch setOn:TRUE];
	[self.onOffSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
	cell.accessoryView = self.onOffSwitch;
}

#pragma mark -
#pragma mark Actions

- (void)switchValueChanged:(id)sender
{
	UISwitch *aOnOffSwitch = (UISwitch *)sender;
	if (aOnOffSwitch.on) {
		self.datePicker.enabled = TRUE;
		self.task.dueAt = [self.datePicker date];
	} else {
		self.datePicker.enabled = FALSE;
		self.task.dueAt = nil;
	}
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[onOffSwitch release];
	[taskDatePickerDataSource release];
	[datePicker release];
	[task release];
	
	[super dealloc];
}

@end
