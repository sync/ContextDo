#import "GroupsEditViewController.h"
#import "TasksViewController.h"

@interface GroupsEditViewController (private)

- (void)groupEditNotification:(NSNotification *)notification;
- (void)groupAddNotification:(NSNotification *)notification;

@end

@implementation GroupsEditViewController

@synthesize groupsEditDataSource, groups;

#pragma mark -
#pragma mark Initialisation

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Edit";
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
	
	self.groupsEditDataSource = [[[GroupsEditDataSource alloc]init]autorelease];
	self.groupsEditDataSource.delegate = self;
	self.tableView.dataSource = self.groupsEditDataSource;
	self.tableView.editing = TRUE;
	self.tableView.allowsSelection = FALSE;
	self.tableView.backgroundColor = [UIColor clearColor];
	[self.groupsEditDataSource.content addObject:self.groups];
}

- (NSMutableArray *)groups
{
	if (!groups) {
		groups = [[NSMutableArray alloc]init];
	}
	
	return groups;
}

#pragma mark -
#pragma mark GroupsDataSourceDelegate

- (void)groupsEditDataSource:(GroupsEditDataSource *)dataSource 
		  commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
		   forRowAtIndexPath:(NSIndexPath *)indexPath;
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		Group *group  = [self.groupsEditDataSource groupForIndexPath:indexPath];
		[[APIServices sharedAPIServices]deleteGroupWitId:group.groupId];
		
		[self.groups removeObjectAtIndex:indexPath.row];
		[self.tableView reloadData];
	}
}

#pragma mark -
#pragma mark TableView Delegate

#pragma mark -
#pragma mark Actions

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[groups release];
	[groupsEditDataSource release];
	
	[super dealloc];
}

@end
