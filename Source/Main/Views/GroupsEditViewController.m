#import "GroupsEditViewController.h"
#import "TasksViewController.h"
#import "CTXDOTableHeaderView.h"
#import "GroupsEditCell.h"

@interface GroupsEditViewController (private)


@end

@implementation GroupsEditViewController

@synthesize groupsEditDataSource, editingTextField, editChangesMade, keyboardShown;

#pragma mark -
#pragma mark Initialisation

- (void)viewDidLoad 
{
	self.title = @"Edit";
	
    [super viewDidLoad];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
}

#pragma mark -
#pragma mark Setup

- (void)setupDataSource
{
	[super setupDataSource];
	
	self.editChangesMade = FALSE;
	
	self.groupsEditDataSource = [[[GroupsEditDataSource alloc]init]autorelease];
	self.groupsEditDataSource.delegate = self;
	self.tableView.dataSource = self.groupsEditDataSource;
	self.tableView.editing = TRUE;
	self.tableView.allowsSelectionDuringEditing = TRUE;
	self.tableView.backgroundColor = [UIColor clearColor];
}

#pragma mark -
#pragma mark BaseLoadingViewCenter Delegate

- (void)baseLoadingViewCenterDidStartForKey:(NSString *)key
{
	// nothing
}

#pragma mark -
#pragma mark GroupsDataSourceDelegate

- (void)groupsEditDataSource:(GroupsEditDataSource *)dataSource 
		  commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
		   forRowAtIndexPath:(NSIndexPath *)indexPath;
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		Group *group  = [self.groupsEditDataSource groupForIndexPath:indexPath];
		[self.groupsEditDataSource.content removeObjectAtIndex:indexPath.row];
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
		
		[[APIServices sharedAPIServices]deleteGroupWitId:group.groupId];
		self.editChangesMade = TRUE;
	}
}

- (void)groupsEditDataSource:(GroupsEditDataSource *)dataSource 
		  moveRowAtIndexPath:(NSIndexPath *)fromIndexPath 
				 toIndexPath:(NSIndexPath *)toIndexPath
{
	Group *group  = [self.groupsEditDataSource groupForIndexPath:fromIndexPath];
	[self.groupsEditDataSource.content exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
	GroupsEditCell *cell = (GroupsEditCell *)[self.tableView cellForRowAtIndexPath:fromIndexPath];
	cell.textField.tag = [self.groupsEditDataSource tagForRow:toIndexPath.row];
	
	
	[[APIServices sharedAPIServices]editGroupWithId:group.groupId name:group.name position:[NSNumber numberWithInteger:toIndexPath.row]];
	self.editChangesMade = TRUE;
}

- (void)refreshDataSourceForGroups:(NSArray *)groups
{
	[self.groupsEditDataSource.content removeAllObjects];
	[self.groupsEditDataSource.content addObjectsFromArray:groups];
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark TableView Delegate

- (void)tableView:(UITableView *)aTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[(GroupsEditCell *)cell textField].delegate = self;
}

- (BOOL)tableView:(UITableView *)aTableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return FALSE;
}

- (NSIndexPath *)tableView:(UITableView *)aTableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
	GroupsEditCell *cell = (GroupsEditCell *)[aTableView cellForRowAtIndexPath:sourceIndexPath];
	[cell.textField resignFirstResponder];
	
	return proposedDestinationIndexPath;
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section
{
	CTXDOTableHeaderView *view = [[[CTXDOTableHeaderView alloc]initWithFrame:CGRectZero]autorelease];
	view.textLabel.shadowOffset = CGSizeMake(0,1);
	view.textLabel.shadowColor = [UIColor whiteColor];
	view.textLabel.text = [self.groupsEditDataSource tableView:self.tableView
									   titleForHeaderInSection:section];
	return view;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section
{
	return 30.0;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	GroupsEditCell *cell = (GroupsEditCell *)[aTableView cellForRowAtIndexPath:indexPath];
	[cell.textField becomeFirstResponder];
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
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.groupsEditDataSource rowForTag:self.editingTextField.tag]
													inSection:0];
		[self.tableView scrollToRowAtIndexPath:indexPath
							  atScrollPosition:UITableViewScrollPositionNone
									  animated:TRUE];
	}
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.groupsEditDataSource rowForTag:textField.tag] inSection:0];
	Group *group =[self.groupsEditDataSource groupForIndexPath:indexPath];
	group.name = textField.text;
	
	return TRUE;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	self.editingTextField = nil;
	
	self.editChangesMade = TRUE;
	
	if (textField.text.length == 0) {
		return;
	}
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.groupsEditDataSource rowForTag:textField.tag] inSection:0];
	Group *group =[self.groupsEditDataSource groupForIndexPath:indexPath];
	group.name = textField.text;
	
	[[APIServices sharedAPIServices]editGroupWithId:group.groupId name:group.name position:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField.text.length == 0) {
		return FALSE;
	}
	
	[textField resignFirstResponder];
	
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
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.groupsEditDataSource rowForTag:self.editingTextField.tag]
																  inSection:0]
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

- (void)startEditingGroups:(NSArray *)groups
{	
	[self refreshDataSourceForGroups:groups];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL)endEditing
{
	[self.editingTextField resignFirstResponder];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	return self.editChangesMade;
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[editingTextField release];
	[groupsEditDataSource release];
	
	[super dealloc];
}

@end
