#import "GroupsEditViewController.h"
#import "TasksViewController.h"
#import "CTXDOTableHeaderView.h"
#import "GroupsEditCell.h"

@interface GroupsEditViewController (private)


@end

@implementation GroupsEditViewController

@synthesize groupsEditDataSource, groups, editingTextField, editChangesMade;

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
	self.tableView.allowsSelection = FALSE;
	self.tableView.backgroundColor = [UIColor clearColor];
	[self refreshDataSource];
}

- (NSMutableArray *)groups
{
	if (!groups) {
		groups = [[NSMutableArray alloc]init];
	}
	
	return groups;
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
		[self.groups removeObjectAtIndex:indexPath.row];
		[[APIServices sharedAPIServices]deleteGroupWitId:group.groupId];
		[self refreshDataSource];
		
		self.editChangesMade = TRUE;
	}
}

- (void)groupsEditDataSource:(GroupsEditDataSource *)dataSource 
		  moveRowAtIndexPath:(NSIndexPath *)fromIndexPath 
				 toIndexPath:(NSIndexPath *)toIndexPath
{
	Group *group  = [self.groupsEditDataSource groupForIndexPath:fromIndexPath];
	[self.groups removeObjectAtIndex:fromIndexPath.row];
	[self.groups insertObject:group atIndex:toIndexPath.row];
	[[APIServices sharedAPIServices]editGroupWithId:group.groupId name:group.name position:[NSNumber numberWithInteger:toIndexPath.row]];
	[self refreshDataSource];
	
	self.editChangesMade = TRUE;
}

- (void)refreshDataSource
{
	[self.groupsEditDataSource.content removeAllObjects];
	[self.groupsEditDataSource.content addObjectsFromArray:self.groups];
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark TableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[(GroupsEditCell *)cell textField].delegate = self;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return FALSE;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	CTXDOTableHeaderView *view = [[[CTXDOTableHeaderView alloc]initWithFrame:CGRectZero]autorelease];
	view.textLabel.shadowOffset = CGSizeMake(0,1);
	view.textLabel.shadowColor = [UIColor whiteColor];
	view.textLabel.text = [self.groupsEditDataSource tableView:self.tableView
									   titleForHeaderInSection:section];
	return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 30.0;
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification object:nil];
	
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	self.editingTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	self.editingTextField = nil;
	[[NSNotificationCenter defaultCenter]removeObserver:self];
	
	self.editChangesMade = TRUE;
	
	if (textField.text.length == 0) {
		return;
	}
	
	[textField resignFirstResponder];
	
	Group *group =[self.groupsEditDataSource groupForIndexPath:[NSIndexPath indexPathForRow:[self.groupsEditDataSource rowForTag:textField.tag] inSection:0]];
	group.name = textField.text;
	[[APIServices sharedAPIServices]editGroupWithId:group.groupId name:group.name position:nil];
	[self refreshDataSource];
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
	[UIView beginAnimations:nil context:NULL]; [UIView setAnimationDuration:animationDuration];
	
	[self.tableView setContentInset:insets];
	[self.tableView setScrollIndicatorInsets:insets];
	if (self.editingTextField) {
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.groupsEditDataSource rowForTag:self.editingTextField.tag]
																  inSection:0]
							  atScrollPosition:UITableViewScrollPositionNone
									  animated:FALSE];
	}
	
	[UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
	// This assumes that no one else cares about the table view's insets...
	NSDictionary *userInfo = [notification userInfo]; 
	
	NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
	NSTimeInterval animationDuration; [animationDurationValue getValue:&animationDuration];
	[UIView beginAnimations:nil context:NULL]; [UIView setAnimationDuration:animationDuration];
	
	[self.tableView setContentInset:UIEdgeInsetsZero];
    [self.tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
	
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark Actions

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[editingTextField release];
	[groups release];
	[groupsEditDataSource release];
	
	[super dealloc];
}

@end
