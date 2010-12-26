#import "GroupsViewController.h"
#import "TasksViewController.h"
#import "GroupEditionViewController.h"

@interface GroupsViewController (private)

- (void)refreshGroups;
- (void)reloadGroups:(NSArray *)newGroups removeCache:(BOOL)removeCache showMore:(BOOL)showMore;
- (void)addGroup;

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
	
	UIBarButtonItem *addItem = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																			 target:self
																			 action:@selector(addGroup)]autorelease];
	self.navigationItem.rightBarButtonItem = addItem;
}

- (void)setupDataSource
{
	[super setupDataSource];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:GroupsDidLoadNotification object:nil];
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
									  name:TodaysTasksPlacholder
								modifiedAt:nil];
	
	[self.groupsDataSource.content addObject:[NSArray arrayWithObject:todayGroup]];
	
	NSMutableArray *section2 = [NSMutableArray array];
	
	[section2 addObjectsFromArray:self.groups];
	
	if (showMore) {
		Group *showMoreGroup = [Group groupWithId:[NSNumber numberWithInt:NSNotFound]
											 name:ShowMorePlaceholder
									   modifiedAt:nil];
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
	
	[self.tableView setEditing:editing animated:animated];
	[self reloadGroups:nil removeCache:FALSE showMore:!editing];
}

#pragma mark -
#pragma mark GroupsDataSourceDelegate

- (void)groupsDataSource:(GroupsDataSource *)dataSource 
	  commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
	   forRowAtIndexPath:(NSIndexPath *)indexPath;
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[self.groups removeObjectAtIndex:indexPath.row];
		[self reloadGroups:nil removeCache:FALSE showMore:FALSE];
		
		if (!self.editing) {
			// TODO update
		}
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
			UINavigationController *navController = [[[UINavigationController alloc]initWithRootViewController:controller]autorelease];
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

- (void)showRefreshHeaderView
{
	[super showRefreshHeaderView];
	
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
	UINavigationController *navController = [[[UINavigationController alloc]initWithRootViewController:controller]autorelease];
	[self.navigationController presentModalViewController:navController animated:TRUE];
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
