#import "GroupsViewController.h"
#import "TasksViewController.h"

@interface GroupsViewController (private)

- (void)refreshGroups;
- (void)reloadGroups:(NSArray *)newGroups removeCache:(BOOL)removeCache showMore:(BOOL)showMore;

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

- (void)setupDataSource
{
	[super setupDataSource];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:GroupsDidLoadNotification object:nil];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:GroupsDidLoadNotification];
	
	self.groupsDataSource = [[[GroupsDataSource alloc]init]autorelease];
	self.tableView.dataSource = self.groupsDataSource;
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
	
	[self hideRefreshHeaderView];
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
	
	NSMutableArray *section1 = [NSMutableArray array];
	
	[section1 addObjectsFromArray:self.groups];
	
	
	if (showMore) {
		Group *showMoreGroup = [Group groupWithId:[NSNumber numberWithInt:NSNotFound]
											 name:ShowMorePlaceholder
									   modifiedAt:nil];
		[section1 addObject:showMoreGroup];
	}
	
	[self.groupsDataSource.content addObject:section1];
	
	Group *todayGroup = [Group groupWithId:[NSNumber numberWithInt:-1]
										 name:TodaysTasksPlacholder
								   modifiedAt:nil];
	
	[self.groupsDataSource.content addObject:[NSArray arrayWithObject:todayGroup]];
	
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark TableView Delegate

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
		} else {
			// todo today's tasks
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
