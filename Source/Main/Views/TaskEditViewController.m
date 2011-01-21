#import "TaskEditViewController.h"
#import "TaskEditCell.h"
#import "ChooseGroupViewController.h"
#import "TaskDatePickerViewController.h"
#import "TaskContactViewController.h"

@interface TaskEditViewController (private)

@end


@implementation TaskEditViewController

@synthesize taskEditDataSource, editingTextField, keyboardShown, task, editingTextView;

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
	
	[self.taskEditDataSource.content addObject:[NSArray arrayWithObject:TitlePlaceholder]];
	[self.taskEditDataSource.content addObject:[NSArray arrayWithObject:LocationPlaceholder]];
	[self.taskEditDataSource.content addObject:[NSArray arrayWithObject:AddContactPlaceholder]];
	[self.taskEditDataSource.content addObject:[NSArray arrayWithObject:TimePlaceholder]];
	[self.taskEditDataSource.content addObject:[NSArray arrayWithObject:AlertsPlaceholder]];
	[self.taskEditDataSource.content addObject:[NSArray arrayWithObject:GroupPlaceholder]];
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
	if ([self.taskEditDataSource hasNoteEdit:indexPath]) {
		context = CTXDOCellContextTaskEditInput;
		[(TaskEditCell *)cell textField].delegate = self;
		[[(TaskEditCell	*)cell noteButton] addTarget:self action:@selector(showInfoCell:) forControlEvents:UIControlEventTouchUpInside];
	} else if ([self.taskEditDataSource isIndexPathInputMulti:indexPath]) {
		context = CTXDOCellContextTaskEditInputMutliLine;
		[(TaskEditCell *)cell textView].delegate = self;
	} else if ([self.taskEditDataSource isIndexPathInput:indexPath]) {
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

- (BOOL)isNoteCellShowing
{
	return ([self.tableView numberOfRowsInSection:0] > 1);
}

- (void)showInfoCell:(id)sender
{
	[self endEditing];
	
	UIButton *button = (UIButton *)sender;
	NSIndexPath *index = [self.taskEditDataSource indexPathForTag:button.tag];
	NSIndexPath *newIndex = [NSIndexPath indexPathForRow:index.row+1 inSection:index.section];
	if (!self.isNoteCellShowing) {
		
		[self.taskEditDataSource.content replaceObjectAtIndex:index.section withObject:[NSArray arrayWithObjects:
																						TitlePlaceholder,
																						InfoPlaceholder,
																						nil]];
		[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndex] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationNone];
		TaskEditCell *cell = (TaskEditCell *)[self.tableView cellForRowAtIndexPath:newIndex];
		[cell.textView becomeFirstResponder];
	} else {
		[self.taskEditDataSource.content replaceObjectAtIndex:index.section withObject:[NSArray arrayWithObjects:
																						TitlePlaceholder,
																						nil]];
		
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:newIndex] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationNone];
	}
	
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0 && indexPath.row == 1) {
		return 70.0;
	}
	
	return self.tableView.rowHeight;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self endEditing];
	if ([self.taskEditDataSource isIndexPathInput:indexPath]) {
		TaskEditCell *cell = (TaskEditCell *)[aTableView cellForRowAtIndexPath:indexPath];
		[cell.textField becomeFirstResponder];
	} else {
		NSString *placeholder = [self.taskEditDataSource objectForIndexPath:indexPath];
		if ([placeholder isEqualToString:GroupPlaceholder]) {
			ChooseGroupViewController *controller = [[[ChooseGroupViewController alloc]initWithNibName:@"ChooseGroupView" bundle:nil]autorelease];
			controller.task = self.taskEditDataSource.tempTask;
			[self.navigationController pushViewController:controller animated:TRUE];
		} else if ([placeholder isEqualToString:TimePlaceholder]) {
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
	if ([placeholder isEqualToString:AddContactPlaceholder]) {
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
	if (self.editingTextView) {
		[self endEditing];
	}
}

#pragma mark -
#pragma mark UITextFieldDelegate

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
	
	NSIndexPath *indexPath = [self.taskEditDataSource indexPathForTag:textField.tag];
	[self.taskEditDataSource setValue:textField.text forIndexPath:indexPath];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[self endEditing];
	
	return TRUE;
}

#pragma mark -
#pragma mark UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	self.editingTextView = textView;
	
	if (self.keyboardShown) {
		NSIndexPath *indexPath = [self.taskEditDataSource indexPathForTag:textView.tag];
		[self.tableView scrollToRowAtIndexPath:indexPath
							  atScrollPosition:UITableViewScrollPositionNone
									  animated:TRUE];
	}
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
	NSIndexPath *indexPath = [self.taskEditDataSource indexPathForTag:textView.tag];
	[self.taskEditDataSource setValue:textView.text forIndexPath:indexPath];
	
	return TRUE;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	self.editingTextView = nil;
	
	NSIndexPath *indexPath = [self.taskEditDataSource indexPathForTag:textView.tag];
	[self.taskEditDataSource setValue:textView.text forIndexPath:indexPath];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	if (text.length == 0) {
		return YES;
	}
	
	CGSize textSize = [textView.text sizeWithFont:textView.font
								constrainedToSize:CGSizeMake(textView.frame.size.width - 10, CGFLOAT_MAX)
									lineBreakMode:UILineBreakModeWordWrap];
	return  (textSize.height < textView.frame.size.height - 20);
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
	[self.editingTextView resignFirstResponder];
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:TaskAddNotification];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[editingTextView release];
	[task release];
	[editingTextField release];
	[taskEditDataSource release];
	
	[super dealloc];
}

@end
