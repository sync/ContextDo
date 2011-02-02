#import "GroupsViewController.h"
#import "TasksViewController.h"
#import "CTXDOTableHeaderView.h"
#import "GroupsCell.h"
#import "TasksContainerViewController.h"
#import "TaskEditViewController.h"
#import "SettingsViewController.h"

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
- (Group *)groupForId:(NSNumber *)groupId;
- (void)showInfoAnimated:(BOOL)animated;
- (void)hideInfoAnimated:(BOOL)animated;
- (void)blackOutMainViewAnimated:(BOOL)animated;
- (void)hideBlackOutMainViewAnimated:(BOOL)animated;
- (void)shouldCheckWithinTasks:(NSArray *)tasks updateCell:(BOOL)updateCell;
@end


@implementation GroupsViewController

@synthesize groupsDataSource, groups, groupsEditViewController, addGroupTextField;
@synthesize infoViewController, isShowingInfoView, blackedOutView, infoButton, hasCachedData;

#pragma mark -
#pragma mark Initialisation

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	self.title = @"Groups";
	
	[self hideInfoAnimated:FALSE];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	[self hideGroupsEditAnimated:FALSE];
	[groupsEditViewController release];
	groupsEditViewController = nil;
	
	[self hideInfoAnimated:FALSE];
	[infoViewController release];
	infoViewController = nil;
	
	self.addGroupTextField = nil;
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
{	[super setupToolbar];
	
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
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldHidInfo) name:GroupShouldDismissInfo object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetWithinTasks:) name:TasksWithinDidLoadNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:GroupsDidLoadNotification object:nil];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:GroupsDidLoadNotification];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:GroupAddNotification];
	
	self.groupsDataSource = [[[GroupsDataSource alloc]init]autorelease];
	self.tableView.dataSource = self.groupsDataSource;
	self.tableView.allowsSelectionDuringEditing = TRUE;
	self.tableView.backgroundColor = [DefaultStyleSheet sharedDefaultStyleSheet].darkBackgroundTexture;
	self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 25.0, 0.0);
	self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0);
	self.addGroupTextField.rightView = [[DefaultStyleSheet sharedDefaultStyleSheet]inputTextFieldButtonWithText:@"Add" 
																										 target:self 
																									   selector:@selector(addGroup)];

	self.tableView.tableHeaderView.hidden = (self.groups.count == 0);
	[self refreshGroups];
}

#pragma mark -
#pragma mark Content reloading

- (void)shouldReloadContent:(NSNotification *)notification
{
	NSArray *newGroups = [notification object];
	[self reloadGroups:newGroups];
}

- (void)reloadGroups:(NSArray *)newGroups
{
	[self.groupsDataSource resetContent];
	
	self.groups = newGroups;
	if (self.groups.count > 0) {
		[self.groupsDataSource.content addObject:self.groups];
	}
	
	Group *todayGroup = [Group groupWithId:[NSNumber numberWithInt:NSNotFound]
									  name:TodaysTasksPlacholder];
	
	Group *nearGroup = [Group groupWithId:[NSNumber numberWithInt:NSNotFound]
									 name:NearTasksPlacholder];
	
	[self.groupsDataSource.content addObject:[NSArray arrayWithObjects:todayGroup, nearGroup, nil]];
	
	self.tableView.tableHeaderView.hidden = (self.groupsDataSource.content.count == 0);
	
	NSArray *tasksWithin = [CacheServices sharedCacheServices].tasksWithin;
	if (tasksWithin.count > 0) {
		[self shouldCheckWithinTasks:tasksWithin updateCell:FALSE];
	}
	
	[self.tableView reloadData];
}

- (Group *)groupForId:(NSNumber *)groupId
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupId == %@", groupId];
	NSArray *foundGroups = [self.groups filteredArrayUsingPredicate:predicate];
	
	return (foundGroups.count > 0) ? [foundGroups objectAtIndex:0] : nil;
}

- (void)didGetWithinTasks:(NSNotification *)notification
{
	NSArray *newTasks = [[notification object] valueForKey:@"tasks"];
	[self shouldCheckWithinTasks:newTasks updateCell:TRUE];
}

- (void)shouldCheckWithinTasks:(NSArray *)tasks updateCell:(BOOL)updateCell
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taskWithin == %@", [NSNumber numberWithBool:TRUE]];
	NSMutableSet *previousNearGroups = [[[self.groups filteredArrayUsingPredicate:predicate]mutableCopy]autorelease];
	
	for (Task *task in tasks) {
		if (task.isClose) {
			Group *group = [self groupForId:task.groupId];
			if (!group.taskWithin) {
				group.taskWithin = TRUE;
				NSInteger row = (group) ? [self.groups indexOfObject:group] : NSNotFound;
				if (updateCell && group && row != NSNotFound && group.dueCount.integerValue == 0) {
					NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
					[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
				}
			} else {
				[previousNearGroups removeObject:group];
			}
		}
	}
	
	for (Group *group in previousNearGroups) {
		group.taskWithin = FALSE;
	}
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	Group *group  = [self.groupsDataSource groupForIndexPath:indexPath];
	
	CTXDOCellContext context = CTXDOCellContextStandard;
	if (group.expiredCount.integerValue > 0) {
		context = CTXDOCellContextDue;
	} else if (group.taskWithin) {
		context = CTXDOCellContextLocationAware;
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
    
	[self.addGroupTextField resignFirstResponder];
	
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
	[super scrollViewDidScroll:scrollView];
	if (!scrollView.dragging || scrollView.decelerating) {
		return;
	}
	
	[self.addGroupTextField resignFirstResponder];
}

#pragma mark -
#pragma mark BaseLoadingViewCenter Delegate

- (void)baseLoadingViewCenterDidStartForKey:(NSString *)key
{
	if (self.hasCachedData) {
		return;
	}
	
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
	NSArray *archivedContent = [[CacheServices sharedCacheServices].groupsDict valueForKey:@"content"];
	self.hasCachedData = (archivedContent != nil);
	[self reloadGroups:archivedContent];
	
	[[APIServices sharedAPIServices]refreshGroups];
}

- (void)addGroup
{
	[self.addGroupTextField resignFirstResponder];
	Group *group = [Group groupWithName:self.addGroupTextField.text position:[NSNumber numberWithInteger:0]];
	[self.addGroupTextField performSelector:@selector(setText:) withObject:nil afterDelay:0.5];
	[[APIServices sharedAPIServices]addGroup:group];
}

- (void)addTask
{
	TaskEditViewController *controller = [[[TaskEditViewController alloc]initWithNibName:@"TaskEditView" bundle:nil]autorelease];
	CustomNavigationController *navController = [[DefaultStyleSheet sharedDefaultStyleSheet]customNavigationControllerWithRoot:controller];
	[self.navigationController presentModalViewController:navController animated:TRUE];
}

- (void)showSettings
{
	[self hideInfoAnimated:TRUE];
	
	SettingsViewController *controller = [[[SettingsViewController alloc]initWithNibName:@"SettingsView" bundle:nil]autorelease];
	CustomNavigationController *navController = [[DefaultStyleSheet sharedDefaultStyleSheet]customNavigationControllerWithRoot:controller];
	[self.navigationController presentModalViewController:navController animated:TRUE];
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

- (IBAction)infoButtonPressed
{
	if (!self.isShowingInfoView) {
		[self showInfoAnimated:TRUE];
	} else {
		[self hideInfoAnimated:TRUE];
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

- (void)hideGroupsEditAnimated:(BOOL)animated
{
	if (!self.isShowingGroupsEdit) {
		return;
	}
	
	self.navigationItem.leftBarButtonItem = nil;
	
	self.navigationItem.leftBarButtonItem = [[DefaultStyleSheet sharedDefaultStyleSheet] editBarButtonItemEditing:FALSE
																										   target:self
																										 selector:@selector(editButtonPressed)];
	
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
#pragma mark InfoViewController

#define InfoHiddenHeight 46.0
#define InfoShowingHeight 290.0

- (InfoViewController *)infoViewController
{
	if (!infoViewController) {
		infoViewController = [[InfoViewController alloc]initWithNibName:@"InfoView" bundle:nil];
		infoViewController.view.userInteractionEnabled = FALSE;
		infoViewController.mainNavController = self.navigationController;
		[self.view addSubview:infoViewController.view];
		[self.view bringSubviewToFront:infoViewController.view];
		[self.view bringSubviewToFront:self.infoButton];
		[self.view bringSubviewToFront:self.groupsEditViewController.view];
	}
	
	return infoViewController;
}

- (BOOL)isShowingInfoView
{
	CGSize boundsSize = self.view.bounds.size;
	return (self.infoViewController.view.frame.origin.y != boundsSize.height  - (boundsSize.height - InfoShowingHeight - InfoHiddenHeight));
}

- (void)showInfoAnimated:(BOOL)animated
{
	if (self.isShowingInfoView) {
		return;
	}
	
	self.infoViewController.view.userInteractionEnabled = TRUE;
	
	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.4];
	}
	
	CGSize boundsSize = self.view.bounds.size;
	[self.infoViewController viewWillAppear:animated];
	self.infoViewController.view.frame = CGRectMake(0.0, 
													boundsSize.height - InfoShowingHeight, 
													boundsSize.width, 
													InfoShowingHeight);
	
	[[AppDelegate sharedAppDelegate]blackOutTopViewElementsAnimated:animated];
	[self blackOutMainViewAnimated:animated];
	
	self.infoButton.frame = CGRectMake(0.0, self.infoViewController.view.frame.origin.y, self.infoButton.frame.size.width, self.infoButton.frame.size.height);
	
	
	if (animated) {
		[UIView commitAnimations];
	}
}

- (void)hideInfoAnimated:(BOOL)animated
{
	if (!self.isShowingInfoView) {
		return;
	}
	
	self.infoViewController.view.userInteractionEnabled = FALSE;
		
	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.4];
	}
	
	CGSize boundsSize = self.view.bounds.size;
	self.infoViewController.view.frame = CGRectMake(0.0, 
													boundsSize.height  - (boundsSize.height - InfoShowingHeight - InfoHiddenHeight), 
													boundsSize.width, 
													InfoShowingHeight);
	
	[[AppDelegate sharedAppDelegate]hideBlackOutTopViewElementsAnimated:animated];
	[self hideBlackOutMainViewAnimated:TRUE];
	
	self.infoButton.frame = CGRectMake(0.0, self.infoViewController.view.frame.origin.y, self.infoButton.frame.size.width, self.infoButton.frame.size.height);
	
	if (animated) {
		[UIView commitAnimations];
	}
}

- (void)shouldHidInfo
{
	[self hideInfoAnimated:TRUE];
}

#pragma mark -
#pragma mark Blackout Main View

- (BOOL)isBlackingOutMainView
{
	return (self.blackedOutView != nil);
}

- (void)blackOutMainViewAnimated:(BOOL)animated
{
	if (self.isBlackingOutMainView) {
		return;
	}
	
	CGSize boundsSize = self.view.bounds.size;
	self.blackedOutView = [[[UIView alloc]initWithFrame:CGRectMake(0.0, 
																   -boundsSize.height,
																   boundsSize.width,
																   boundsSize.height)]autorelease];
	self.blackedOutView.backgroundColor = [DefaultStyleSheet sharedDefaultStyleSheet].blackedOutColor;
	[self.view insertSubview:self.blackedOutView belowSubview:self.infoViewController.view];
	
	
	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDelay:0.1];
		[UIView setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	}
	
	self.blackedOutView.frame = CGRectMake(0.0, 
										   0.0,
										   boundsSize.width,
										   boundsSize.height);
	
	if (animated) {
		[UIView commitAnimations];
	}
}

- (void)hideBlackOutMainViewAnimated:(BOOL)animated
{
	if (!self.isBlackingOutMainView) {
		return;
	}
	
	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(hideBlackoutAnimationDidStop)];
	}
	
	CGSize boundsSize = self.view.bounds.size;
	self.blackedOutView.frame = CGRectMake(0.0, 
										   -boundsSize.height,
										   boundsSize.width,
										   boundsSize.height);
	
	if (animated) {
		[UIView commitAnimations];
	}
}

- (void)hideBlackoutAnimationDidStop
{
	[self.blackedOutView removeFromSuperview];
	blackedOutView = nil;
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
#pragma mark EGORefreshTableHeaderDelegate 

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{	
	[self refreshGroups];
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:GroupsDidLoadNotification];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:GroupAddNotification];
	
	[infoButton release];
	[infoViewController release];
	[addGroupTextField release];
	[groupsEditViewController release];
	[groups release];
	[groupsDataSource release];
	
	[super dealloc];
}

@end
