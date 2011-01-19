#import "GroupsViewController.h"
#import "TasksViewController.h"
#import "CTXDOTableHeaderView.h"
#import "GroupsCell.h"
#import "TasksContainerViewController.h"

@interface GroupsViewController (private)

- (void)refreshGroups;
- (void)reloadGroups:(NSArray *)newGroups;
- (void)addGroup;
- (void)groupEditNotification:(NSNotification *)notification;
- (void)groupAddNotification:(NSNotification *)notification;
- (void)addTask;
- (void)showSettings;
- (void)showGroupsEditAnimated:(BOOL)animated;
- (void)hideGroupsEditAnimated:(BOOL)animated;
- (BOOL)isIndexPathLastRow:(NSIndexPath *)indexPath;
- (BOOL)isIndexPathSingleRow:(NSIndexPath *)indexPath;
@end


@implementation GroupsViewController

@synthesize groupsDataSource, groups, groupsEditViewController, addGroupTextField;

#pragma mark -
#pragma mark Initialisation

- (void)viewDidLoad 
{
    self.title = @"Groups";
	
	[super viewDidLoad];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	[self hideGroupsEditAnimated:FALSE];
	[groupsEditViewController release];
	groupsEditViewController = nil;
}

#pragma mark -
#pragma mark Setup

- (void)setupNavigationBar
{
	[super setupNavigationBar];
	
	self.navigationItem.leftBarButtonItem = self.editButtonItem;
	
	self.navigationItem.titleView = [[DefaultStyleSheet sharedDefaultStyleSheet] titleViewWithText:self.title];
}

- (void)setupToolbar
{	
	[self.navigationController setToolbarHidden:FALSE animated:FALSE];
	
	UIBarButtonItem *settingsItem = [[DefaultStyleSheet sharedDefaultStyleSheet] buttonItemWithImageNamed:@"icon_settings_off.png" 
																					highlightedImageNamed:@"icon_settings_touch.png"
																								   target:self 
																								 selector:@selector(showSettings)];
	
	UIBarButtonItem *flexItem = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			  target:nil
																			  action:nil]autorelease];
	
	UIBarButtonItem *addItem = [[DefaultStyleSheet sharedDefaultStyleSheet] buttonItemWithImageNamed:@"icon_add_off.png" 
																			   highlightedImageNamed:@"icon_add_touch.png"
																							  target:self 
																							selector:@selector(addTask)];
	
	
	NSArray *items = [NSArray arrayWithObjects:
					  settingsItem,
					  flexItem,
					  addItem,
					  nil];
	[self setToolbarItems:items animated:FALSE];
}

- (void)setupDataSource
{
	[super setupDataSource];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:GroupsDidLoadNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupEditNotification:) name:GroupEditNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupAddNotification:) name:GroupAddNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupDeletedNotification:) name:GroupDeleteNotification object:nil];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:GroupsDidLoadNotification];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:GroupAddNotification];
	
	self.groupsDataSource = [[[GroupsDataSource alloc]init]autorelease];
	self.tableView.dataSource = self.groupsDataSource;
	self.tableView.allowsSelectionDuringEditing = TRUE;
	self.tableView.backgroundView = [DefaultStyleSheet sharedDefaultStyleSheet].backgroundTextureView;
	[self refreshGroups];
	self.addGroupTextField.rightView = [[DefaultStyleSheet sharedDefaultStyleSheet]inputTextFieldButtonWithText:@"Add" 
																										 target:self 
																									   selector:@selector(addGroup)];

	self.tableView.tableHeaderView.hidden = (self.groupsDataSource.content.count == 0);
}

#pragma mark -
#pragma mark Content reloading

- (void)shouldReloadContent:(NSNotification *)notification
{
	NSArray *newGroups = [notification object];
	[self reloadGroups:newGroups];
}

- (void)groupEditNotification:(NSNotification *)notification
{
	NSDictionary *dict = [notification object];
	
	Group *group = [dict valueForKey:@"object"];
	if (group) {
//		NSInteger index = [self.groups indexOfObject:group];
//		if (index != NSNotFound) {
//			[self.groups replaceObjectAtIndex:index withObject:group];
//			[self.tableView reloadData];
//		}
		if (!self.isShowingGroupsEdit) {
			[self refreshGroups];
		}
	}
}

- (void)groupAddNotification:(NSNotification *)notification
{
	NSDictionary *dict = [notification object];
	Group *group = [dict valueForKey:@"object"];
	if (group) {
		NSString *groupName = [dict valueForKey:@"name"];
		if ([groupName isEqualToString:self.addGroupTextField.text]) {
			self.addGroupTextField.text = nil;
		}
		if (!self.isShowingGroupsEdit) {
			[self refreshGroups];
		}
	}
}

- (void)groupDeletedNotification:(NSNotification *)notification
{
	if (!self.isShowingGroupsEdit) {
		[self refreshGroups];
	}
}

- (NSMutableArray *)groups
{
	if (!groups) {
		groups = [[NSMutableArray alloc]init];
	}
	
	return groups;
}

- (void)reloadGroups:(NSArray *)newGroups
{
	[self.groupsDataSource resetContent];
	
	[self.groups removeAllObjects];
	
	if (newGroups.count > 0) {
		[self.groups addObjectsFromArray:newGroups];
		[self.groupsDataSource.content addObject:self.groups];
	}
	Group *todayGroup = [Group groupWithId:[NSNumber numberWithInt:NSNotFound]
									  name:TodaysTasksPlacholder];
	
	[self.groupsDataSource.content addObject:[NSArray arrayWithObject:todayGroup]];
	
	self.tableView.tableHeaderView.hidden = (self.groupsDataSource.content.count == 0);
	
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Editing

- (UIBarButtonItem *)editButtonItem
{
	return [[DefaultStyleSheet sharedDefaultStyleSheet] editBarButtonItemEditing:self.isShowingGroupsEdit
																		  target:self
																		selector:@selector(editButtonPressed)];
}

#pragma mark -
#pragma mark TableView Delegate

- (BOOL)isIndexPathLastRow:(NSIndexPath *)indexPath
{
	return ([self.tableView numberOfRowsInSection:indexPath.section] - 1 == indexPath.row);
}

- (BOOL)isIndexPathSingleRow:(NSIndexPath *)indexPath
{
	return ([self.tableView numberOfRowsInSection:indexPath.section] == 1);
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	Group *group  = [self.groupsDataSource groupForIndexPath:indexPath];
	
	CTXDOCellContext context = CTXDOCellContextStandard;
	if (group.expiredCount.integerValue > 0) {
		context = CTXDOCellContextDue;
	} else if (group.dueCount.integerValue > 0) {
		context = CTXDOCellContextExpiring;
	}
	
	if ([self isIndexPathSingleRow:indexPath]) {
		[(GroupsCell *)cell setCellPosition:CTXDOCellPositionSingle context:context];
	} else if (indexPath.row == 0) {
		[(GroupsCell *)cell setCellPosition:CTXDOCellPositionTop context:context];
	} else if ([self isIndexPathLastRow:indexPath]) {
		[(GroupsCell *)cell setCellPosition:CTXDOCellPositionBottom context:context];
	} else {
		[(GroupsCell *)cell setCellPosition:CTXDOCellPositionMiddle context:context];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	Group *group  = [self.groupsDataSource groupForIndexPath:indexPath];
	
	TasksContainerViewController *controller = [[[TasksContainerViewController alloc]initWithNibName:@"TasksContainerView" bundle:nil]autorelease];
	controller.group = group;
	[self.navigationController pushViewController:controller animated:TRUE];
	
	[tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	CTXDOTableHeaderView *view = [[[CTXDOTableHeaderView alloc]initWithFrame:CGRectZero]autorelease];
	view.textLabel.text = [self.groupsDataSource tableView:self.tableView
								   titleForHeaderInSection:section];
	return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 40.0;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (!scrollView.dragging || scrollView.decelerating) {
		return;
	}
	
	[self.addGroupTextField resignFirstResponder];
}

#pragma mark -
#pragma mark BaseLoadingViewCenter Delegate

- (void)baseLoadingViewCenterDidStartForKey:(NSString *)key
{
	if (self.isShowingGroupsEdit) {
		return;
	}
	
	[self.noResultsView hide:FALSE];
	
	if (!self.loadingView) {
		self.loadingView = [[[MBProgressHUD alloc] initWithView:self.view]autorelease];
		self.loadingView.delegate = self;
		[self.view addSubview:self.loadingView];
		[self.view bringSubviewToFront:self.loadingView];
		[self.loadingView show:TRUE];
	}
	self.loadingView.labelText = @"Loading";
}

#pragma mark -
#pragma mark Actions

- (void)refreshGroups
{
	[[APIServices sharedAPIServices]refreshGroups];
}

- (void)addGroup
{
	[self.addGroupTextField resignFirstResponder];
	[[APIServices sharedAPIServices]addGroupWithName:self.addGroupTextField.text position:[NSNumber numberWithInteger:1]];
}

- (void)addTask
{
	// todo
}

- (void)showSettings
{
	// todo
}

- (void)editButtonPressed
{
	if (!self.isShowingGroupsEdit) {
		[self showGroupsEditAnimated:TRUE];
	} else {
		[self.groupsEditViewController.editingTextField resignFirstResponder];
		[self hideGroupsEditAnimated:TRUE];
	}
}

#pragma mark -
#pragma mark GroupsEditViewController

- (GroupsEditViewController *)groupsEditViewController
{
	if (!groupsEditViewController) {
		groupsEditViewController = [[GroupsEditViewController alloc]initWithNibName:@"GroupsEditView" bundle:nil];
		CGSize boundsSize = self.view.bounds.size;
		groupsEditViewController.view.frame = CGRectMake(0.0, boundsSize.height, boundsSize.width, boundsSize.height);
		[self.view addSubview:groupsEditViewController.view];
		[self.view bringSubviewToFront:groupsEditViewController.view];
	}
	
	return groupsEditViewController;
}

- (BOOL)isShowingGroupsEdit
{
	return (self.groupsEditViewController.view.frame.origin.y == 0);
}

- (void)showGroupsEditAnimated:(BOOL)animated
{
	if (self.isShowingGroupsEdit) {
		return;
	}
	

	self.navigationItem.leftBarButtonItem = [[DefaultStyleSheet sharedDefaultStyleSheet] editBarButtonItemEditing:TRUE
																										   target:self
																										 selector:@selector(editButtonPressed)];
	
	[self.groupsEditViewController startEditingGroups:self.groups];
	
	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.4];
	}
	
	CGSize boundsSize = self.view.bounds.size;
	self.groupsEditViewController.view.frame = CGRectMake(0.0, 0.0, boundsSize.width, boundsSize.height);
	
	if (animated) {
		[UIView commitAnimations];
	}
}

- (void)hideGroupsEditAnimated:(BOOL)animated;
{
	if (!self.isShowingGroupsEdit) {
		return;
	}
	
	
	
	if ([self.groupsEditViewController endEditing]) {
		[self refreshGroups];
	}
	
	self.navigationItem.leftBarButtonItem = nil;
	
	self.navigationItem.leftBarButtonItem = [[DefaultStyleSheet sharedDefaultStyleSheet] editBarButtonItemEditing:FALSE
																										   target:self
																										 selector:@selector(editButtonPressed)];
	//self.navigationItem.rightBarButtonItem = nil;
	
	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.4];
	}
	
	CGSize boundsSize = self.view.bounds.size;
	self.groupsEditViewController.view.frame = CGRectMake(0.0, boundsSize.height, boundsSize.width, boundsSize.height);
	
	if (animated) {
		[UIView commitAnimations];
	}
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[self.navigationItem setLeftBarButtonItem:nil animated:TRUE];
	
	[(CTXDODarkTextField *)textField updateBackgroundImage];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	[self.navigationItem setLeftBarButtonItem:[[DefaultStyleSheet sharedDefaultStyleSheet] editBarButtonItemEditing:FALSE
																											 target:self
																										  selector:@selector(editButtonPressed)] animated:TRUE];
	
	
	[(CTXDODarkTextField *)textField updateBackgroundImage];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField.text.length > 0) {
		[self addGroup];
	}
	return YES;
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:GroupsDidLoadNotification];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:GroupAddNotification];
	
	[addGroupTextField release];
	[groupsEditViewController release];
	[groups release];
	[groupsDataSource release];
	
	[super dealloc];
}

@end
