#import "GroupsViewController.h"
#import "TasksViewController.h"
#import "GroupEditionViewController.h"
#import "CTXDOTableHeaderView.h"
#import "GroupsCell.h"

@interface GroupsViewController (private)

- (void)refreshGroups;
- (void)reloadGroups:(NSArray *)newGroups removeCache:(BOOL)removeCache showMore:(BOOL)showMore;
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

@synthesize groupsDataSource, groups, page, groupsEditViewController, addGroupTextField;

#pragma mark -
#pragma mark Initialisation

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Groups";
	
	self.page = 1;
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
	NSDictionary *dict = [notification object];
	
	NSNumber *currentPage = [dict valueForKey:@"object"];
	self.page = currentPage.integerValue;
	
	NSArray *newGroups = [dict valueForKey:@"groups"];
	[self reloadGroups:newGroups removeCache:(self.page == 1) showMore:newGroups.count == 10];
}

- (void)groupEditNotification:(NSNotification *)notification
{
	NSDictionary *dict = [notification object];
	
	Group *group = [dict valueForKey:@"object"];
	if (group) {
		NSInteger index = [self.groups indexOfObject:group];
		if (index != NSNotFound) {
			[self.groups replaceObjectAtIndex:index withObject:group];
			[self.tableView reloadData];
		}
		
	}
}

- (void)groupAddNotification:(NSNotification *)notification
{
	[self refreshGroups];
}

- (NSMutableArray *)groups
{
	if (!groups) {
		groups = [[NSMutableArray alloc]init];
	}
	
	return groups;
}

#define ShowMorePlaceholder @"Load More Groups..."

- (void)reloadGroups:(NSArray *)newGroups removeCache:(BOOL)removeCache showMore:(BOOL)showMore
{
	[self.groupsDataSource resetContent];
	
	if (removeCache) {
		[self.groups removeAllObjects];
	}
	
	if (newGroups) {
		[self.groups addObjectsFromArray:newGroups];
	}
	
	NSMutableArray *groupsSection = [NSMutableArray array];
	
	[groupsSection addObjectsFromArray:self.groups];
	
	if (showMore) {
		Group *showMoreGroup = [Group groupWithId:[NSNumber numberWithInt:NSNotFound]
											 name:ShowMorePlaceholder];
		[groupsSection addObject:showMoreGroup];
	}
	
	[self.groupsDataSource.content addObject:groupsSection];
	
	Group *todayGroup = [Group groupWithId:[NSNumber numberWithInt:-1]
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

- (UIBarButtonItem *)saveButtonItem
{
	return [[DefaultStyleSheet sharedDefaultStyleSheet] doneNavBarButtonItemWithText:@"Save" 
																			  target:self 
																			selector:@selector(saveButtonPressed)];
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
	if ([self isIndexPathSingleRow:indexPath]) {
		[(GroupsCell *)cell setCellPosition:CTXDOCellPositionSingle context:CTXDOCellContextStandard];
	} else if (indexPath.row == 0) {
		[(GroupsCell *)cell setCellPosition:CTXDOCellPositionTop context:CTXDOCellContextDue];
	} else if ([self isIndexPathLastRow:indexPath]) {
		[(GroupsCell *)cell setCellPosition:CTXDOCellPositionBottom context:CTXDOCellContextLocationAware];
	} else {
		[(GroupsCell *)cell setCellPosition:CTXDOCellPositionMiddle context:CTXDOCellContextExpiring];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	Group *group  = [self.groupsDataSource groupForIndexPath:indexPath];
	
	if (group.groupId.integerValue != NSNotFound) {
		TasksViewController *controller = [[[TasksViewController alloc]initWithNibName:@"TasksView" bundle:nil]autorelease];
		controller.group = group;
		[self.navigationController pushViewController:controller animated:TRUE];
	} else {
		if ([group.name isEqualToString:ShowMorePlaceholder]) {
			self.page += 1;
			[[APIServices sharedAPIServices]refreshGroupsWithPage:self.page];
		}
	}
	
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
#pragma mark Actions

- (void)refreshGroups
{
	self.page = 1;
	
	[[APIServices sharedAPIServices]refreshGroupsWithPage:page];
}

- (void)addGroup
{
	[self.addGroupTextField resignFirstResponder];
	[[APIServices sharedAPIServices]addGroupWithName:self.addGroupTextField.text];
	self.addGroupTextField.text = nil;
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
		[self hideGroupsEditAnimated:TRUE];
	}
}

- (void)saveButtonPressed
{
	[self hideGroupsEditAnimated:TRUE];
	// TODO sync with server
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
	[self.navigationItem setRightBarButtonItem:self.saveButtonItem animated:TRUE];
	
	[self.groupsEditViewController.groups removeAllObjects];
	[self.groupsEditViewController.groups addObjectsFromArray:self.groups];
	[self.groupsEditViewController refreshDataSource];
	
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
	
	self.navigationItem.leftBarButtonItem = [[DefaultStyleSheet sharedDefaultStyleSheet] editBarButtonItemEditing:FALSE
																										   target:self
																										 selector:@selector(editButtonPressed)];
	self.navigationItem.rightBarButtonItem = nil;
	
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
