#import "TaskEditViewController.h"
#import "TaskEditCell.h"
#import "ChooseGroupViewController.h"
#import "TaskDatePickerViewController.h"
#import "TaskContactViewController.h"

@interface TaskEditViewController (private)

@end


@implementation TaskEditViewController

@synthesize taskEditDataSource, editingTextField, keyboardShown, task;

#pragma mark -
#pragma mark Initialisation

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self endEditing];
}

- (void)viewDidLoad 
{
	if (!self.task) {
		self.title = @"Add to do";
	} else {
		self.title = @"Edit to do";
	}
	
    [super viewDidLoad];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
}

#pragma mark -
#pragma mark Setup

- (void)setupNavigationBar
{
	[super setupNavigationBar];
	
	self.navigationItem.rightBarButtonItem = [[DefaultStyleSheet sharedDefaultStyleSheet] doneNavBarButtonItemWithText:@"Done"
																												target:self
																											  selector:@selector(saveTouched)];
	
	self.navigationItem.leftBarButtonItem = [[DefaultStyleSheet sharedDefaultStyleSheet] navBarButtonItemWithText:@"Cancel"
																										   target:self
																										 selector:@selector(cancelTouched)];
	
	self.navigationItem.titleView = [[DefaultStyleSheet sharedDefaultStyleSheet] titleViewWithText:self.title];
}

- (void)setupDataSource
{
	[super setupDataSource];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification object:nil];
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:TaskAddNotification object:nil];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:TaskAddNotification];
	self.taskEditDataSource = [[[TaskEditDataSource alloc]init]autorelease];
	self.tableView.dataSource = self.taskEditDataSource;
	self.tableView.backgroundColor = [DefaultStyleSheet sharedDefaultStyleSheet].backgroundTexture;
	self.taskEditDataSource.tempTask = (self.task) ? [[self.task copy]autorelease] : [[[Task alloc]init]autorelease];
	self.tableView.sectionFooterHeight = 0.0;
	self.tableView.sectionHeaderHeight = 12.0;
	
	[self.taskEditDataSource.content addObject:[NSArray arrayWithObject:TitlePlaceHolder]];
	[self.taskEditDataSource.content addObject:[NSArray arrayWithObject:LocationPlaceHolder]];
	[self.taskEditDataSource.content addObject:[NSArray arrayWithObject:AddContactPlaceHolder]];
	[self.taskEditDataSource.content addObject:[NSArray arrayWithObject:TimePlaceHolder]];
	[self.taskEditDataSource.content addObject:[NSArray arrayWithObject:AlertsPlaceHolder]];
	[self.taskEditDataSource.content addObject:[NSArray arrayWithObject:GroupPlaceHolder]];
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Content reloading

- (void)shouldReloadContent:(NSNotification *)notification
{
	[self dismissModalViewControllerAnimated:TRUE];
}

#pragma mark -
#pragma mark BaseLoadingViewCenter Delegate

- (void)baseLoadingViewCenterDidStartForKey:(NSString *)key
{
	[self.noResultsView hide:FALSE];
	
	if (!self.loadingView) {
		self.loadingView = [[[MBProgressHUD alloc] initWithView:self.view]autorelease];
		self.loadingView.delegate = self;
		[self.view addSubview:self.loadingView];
		[self.view bringSubviewToFront:self.loadingView];
		[self.loadingView show:TRUE];
	}
	if (!self.task) {
		self.loadingView.labelText = @"Creating";
	} else {
		self.loadingView.labelText = @"Updating";
	}
}

#pragma mark -
#pragma mark TableView Delegate

- (void)tableView:(UITableView *)aTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	CTXDOCellContext context = CTXDOCellContextTaskEdit;
	if ([self.taskEditDataSource isIndexPathInput:indexPath]) {
		context = CTXDOCellContextTaskEditInput;
		[(TaskEditCell *)cell textField].delegate = self;
	} else { 
		context = CTXDOCellContextTaskEdit;
	}
	
	if ([self isIndexPathSingleRow:indexPath]) {
		[(TaskEditCell *)cell setCellPosition:CTXDOCellPositionSingle context:context];
	} else if (indexPath.row == 0) {
		[(TaskEditCell *)cell setCellPosition:CTXDOCellPositionTop context:context];
	} else if ([self isIndexPathLastRow:indexPath]) {
		[(TaskEditCell *)cell setCellPosition:CTXDOCellPositionBottom context:context];
	} else {
		[(TaskEditCell *)cell setCellPosition:CTXDOCellPositionMiddle context:context];
	}
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self endEditing];
	if ([self.taskEditDataSource isIndexPathInput:indexPath]) {
		TaskEditCell *cell = (TaskEditCell *)[aTableView cellForRowAtIndexPath:indexPath];
		[cell.textField becomeFirstResponder];
	} else {
		NSString *placeholder = [self.taskEditDataSource objectForIndexPath:indexPath];
		if ([placeholder isEqualToString:GroupPlaceHolder]) {
			ChooseGroupViewController *controller = [[[ChooseGroupViewController alloc]initWithNibName:@"ChooseGroupView" bundle:nil]autorelease];
			controller.task = self.taskEditDataSource.tempTask;
			[self.navigationController pushViewController:controller animated:TRUE];
		} else if ([placeholder isEqualToString:TimePlaceHolder]) {
			TaskDatePickerViewController *controller = [[[TaskDatePickerViewController alloc]initWithNibName:@"TaskDatePickerView" bundle:nil]autorelease];
			controller.task = self.taskEditDataSource.tempTask;
			[self.navigationController pushViewController:controller animated:TRUE];
		}
	}
	
	[self.tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	[self endEditing];
	NSString *placeholder = [self.taskEditDataSource objectForIndexPath:indexPath];
	if ([placeholder isEqualToString:AddContactPlaceHolder]) {
		TaskContactViewController *controller = [[[TaskContactViewController alloc]initWithNibName:@"TaskContactView" bundle:nil]autorelease];
		controller.task = self.taskEditDataSource.tempTask;
		[self.navigationController pushViewController:controller animated:TRUE];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (!scrollView.dragging || scrollView.decelerating) {
		return;
	}
	
	[self endEditing];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{	
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	self.editingTextField = textField;
	
	if (self.keyboardShown) {
		NSIndexPath *indexPath = [self.taskEditDataSource indexPathForTag:textField.tag];
		[self.tableView scrollToRowAtIndexPath:indexPath
							  atScrollPosition:UITableViewScrollPositionNone
									  animated:TRUE];
	}
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
	NSIndexPath *indexPath = [self.taskEditDataSource indexPathForTag:textField.tag];
	[self.taskEditDataSource setValue:textField.text forIndexPath:indexPath];
	
	return TRUE;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	self.editingTextField = nil;
	
	if (textField.text.length == 0) {
		return;
	}
	
	NSIndexPath *indexPath = [self.taskEditDataSource indexPathForTag:textField.tag];
	[self.taskEditDataSource setValue:textField.text forIndexPath:indexPath];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField.text.length == 0) {
		return FALSE;
	}
	
	[self endEditing];
	
	return TRUE;
}

#pragma mark -
#pragma mark Keyboard

- (void)keyboardWillShow:(NSNotification *)notification
{
	if (self.keyboardShown) {
		return;
	}
	
	NSDictionary *userInfo = [notification userInfo]; 
	NSValue* keyboardOriginValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]; 
	CGRect keyboardRect = [self.tableView convertRect:[keyboardOriginValue CGRectValue] fromView:nil];
	CGFloat keyboardTop = keyboardRect.origin.y;
	
	// This assumes that no one else cares about the table view's insets...
	UIEdgeInsets insets = UIEdgeInsetsMake(0, 
										   0, 
										   keyboardTop + 30.0, 
										   0);
	
	NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
	NSTimeInterval animationDuration; [animationDurationValue getValue:&animationDuration];
	[UIView beginAnimations:nil context:NULL]; 
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:animationDuration];
	
	[self.tableView setContentInset:insets];
	[self.tableView setScrollIndicatorInsets:insets];
	if (self.editingTextField) {
		[self.tableView scrollToRowAtIndexPath:[self.taskEditDataSource indexPathForTag:self.editingTextField.tag]
							  atScrollPosition:UITableViewScrollPositionBottom
									  animated:FALSE];
	}
	
	[UIView commitAnimations];
	
	self.keyboardShown = TRUE;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
	if (!self.keyboardShown) {
		return;
	}
	
	// This assumes that no one else cares about the table view's insets...
	NSDictionary *userInfo = [notification userInfo]; 
	
	NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
	NSTimeInterval animationDuration; [animationDurationValue getValue:&animationDuration];
	[UIView beginAnimations:nil context:NULL]; 
	[UIView setAnimationDuration:animationDuration];
	[UIView setAnimationBeginsFromCurrentState:YES];
	
	[self.tableView setContentInset:UIEdgeInsetsZero];
    [self.tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
	
	[UIView commitAnimations];
	
	self.keyboardShown = FALSE;
}

#pragma mark -
#pragma mark Actions

- (void)cancelTouched
{
	[self dismissModalViewControllerAnimated:TRUE];
}

- (void)saveTouched
{
	if (self.taskEditDataSource.tempTask.name.length == 0 ||
		self.taskEditDataSource.tempTask.location.length == 0 ||
		!self.taskEditDataSource.tempTask.groupId) {
		// todo error msg
		return;
	}
	
	if (self.task) {
		[[APIServices sharedAPIServices]editTask:self.taskEditDataSource.tempTask];
	} else {
		[[APIServices sharedAPIServices]addTask:self.taskEditDataSource.tempTask];
	}
	[self dismissModalViewControllerAnimated:TRUE];
}

- (void)startEditing
{
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	if ([self.taskEditDataSource isIndexPathInput:indexPath]) {
		TaskEditCell *cell = (TaskEditCell *)[self.tableView cellForRowAtIndexPath:indexPath];
		[cell.textField becomeFirstResponder];
	}	
}

- (void)endEditing
{
	[self.editingTextField resignFirstResponder];
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:TaskAddNotification];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[task release];
	[editingTextField release];
	[taskEditDataSource release];
	
	[super dealloc];
}

@end
