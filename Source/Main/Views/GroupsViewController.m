#import "GroupsViewController.h"
#import "TasksViewController.h"
#import "GroupEditionViewController.h"

@interface GroupsViewController (private)

- (void)refreshGroups;
- (void)reloadGroups:(NSArray *)newGroups removeCache:(BOOL)removeCache showMore:(BOOL)showMore;
- (void)addGroup;
- (void)groupEditNotification:(NSNotification *)notification;
- (void)groupAddNotification:(NSNotification *)notification;
- (void)addTask;
- (void)showSettings;

@end


@implementation GroupsViewController

@synthesize groupsDataSource, groups, page;

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
	
	self.groupsDataSource = [[[GroupsDataSource alloc]init]autorelease];
	self.groupsDataSource.delegate = self;
	self.tableView.dataSource = self.groupsDataSource;
	self.tableView.allowsSelectionDuringEditing = TRUE;
	[self refreshGroups];
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
	
	Group *todayGroup = [Group groupWithId:[NSNumber numberWithInt:-1]
									  name:TodaysTasksPlacholder];
	
	[self.groupsDataSource.content addObject:[NSArray arrayWithObject:todayGroup]];
	
	NSMutableArray *section2 = [NSMutableArray array];
	
	[section2 addObjectsFromArray:self.groups];
	
	if (showMore) {
		Group *showMoreGroup = [Group groupWithId:[NSNumber numberWithInt:NSNotFound]
											 name:ShowMorePlaceholder];
		[section2 addObject:showMoreGroup];
	}
	
	[self.groupsDataSource.content addObject:section2];
	
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Editing

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	
	[self.navigationItem setLeftBarButtonItem:self.editButtonItem animated:FALSE];
	
	[self.tableView setEditing:editing animated:animated];
	[self reloadGroups:nil removeCache:FALSE showMore:!editing];
}

- (void)editButtonPressed:(id)sender
{
	[self setEditing:!self.editing animated:TRUE];
}

- (UIBarButtonItem *)editButtonItem
{
	return [[DefaultStyleSheet sharedDefaultStyleSheet] editBarButtonItemEditing:self.editing
																		  target:self
																		selector:@selector(editButtonPressed:)];
}

#pragma mark -
#pragma mark GroupsDataSourceDelegate

- (void)groupsDataSource:(GroupsDataSource *)dataSource 
	  commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
	   forRowAtIndexPath:(NSIndexPath *)indexPath;
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		Group *group  = [self.groupsDataSource groupForIndexPath:indexPath];
		[[APIServices sharedAPIServices]deleteGroupWitId:group.groupId];
		
		[self.groups removeObjectAtIndex:indexPath.row];
		[self reloadGroups:nil removeCache:FALSE showMore:FALSE];
	}
}

#pragma mark -
#pragma mark TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	Group *group  = [self.groupsDataSource groupForIndexPath:indexPath];
	
	if (group.groupId.integerValue != NSNotFound) {
		if (group.groupId.integerValue == -1 || !self.editing) {
			TasksViewController *controller = [[[TasksViewController alloc]initWithNibName:@"TasksView" bundle:nil]autorelease];
			controller.group = group;
			[self.navigationController pushViewController:controller animated:TRUE];
		} else {
			GroupEditionViewController *controller = [[[GroupEditionViewController alloc]initWithNibName:@"GroupEditionView" bundle:nil]autorelease];
			controller.group = group;
			CustomNavigationController *navController = [[[CustomNavigationController alloc]initWithRootViewController:controller]autorelease];
			[navController.customNavigationBar setBackgroundImage:[DefaultStyleSheet sharedDefaultStyleSheet].navBarBackgroundImage
													  forBarStyle:UIBarStyleDefault];
			[self.navigationController presentModalViewController:navController animated:TRUE];
		}
	} else {
		if ([group.name isEqualToString:ShowMorePlaceholder]) {
			self.page += 1;
			[[APIServices sharedAPIServices]refreshGroupsWithPage:self.page];
		}
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate 

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{	
	[self refreshGroups];
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
	GroupEditionViewController *controller = [[[GroupEditionViewController alloc]initWithNibName:@"GroupEditionView" bundle:nil]autorelease];
	CustomNavigationController *navController = [[[CustomNavigationController alloc]initWithRootViewController:controller]autorelease];
	[navController.customNavigationBar setBackgroundImage:[DefaultStyleSheet sharedDefaultStyleSheet].navBarBackgroundImage
											  forBarStyle:UIBarStyleDefault];
	[self.navigationController presentModalViewController:navController animated:TRUE];
}

- (void)addTask
{
	// todo
}

- (void)showSettings
{
	// todo
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:GroupsDidLoadNotification];
	
	[groups release];
	[groupsDataSource release];
	
	[super dealloc];
}

@end
