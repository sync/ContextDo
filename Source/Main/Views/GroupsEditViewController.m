#import "GroupsEditViewController.h"
#import "TasksViewController.h"
#import "CTXDOTableHeaderView.h"

@interface GroupsEditViewController (private)


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
#pragma mark GroupsDataSourceDelegate

- (void)groupsEditDataSource:(GroupsEditDataSource *)dataSource 
		  commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
		   forRowAtIndexPath:(NSIndexPath *)indexPath;
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[self.groups removeObjectAtIndex:indexPath.row];
		[self refreshDataSource];
	}
}

- (void)groupsEditDataSource:(GroupsEditDataSource *)dataSource 
		  moveRowAtIndexPath:(NSIndexPath *)fromIndexPath 
				 toIndexPath:(NSIndexPath *)toIndexPath
{
	Group *group  = [self.groupsEditDataSource groupForIndexPath:fromIndexPath];
	[self.groups removeObjectAtIndex:fromIndexPath.row];
	[self.groups insertObject:group atIndex:toIndexPath.row];
	[self refreshDataSource];
}

- (void)refreshDataSource
{
	[self.groupsEditDataSource.content removeAllObjects];
	[self.groupsEditDataSource.content addObjectsFromArray:self.groups];
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark TableView Delegate

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
