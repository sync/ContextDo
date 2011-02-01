#import "ChooseGroupViewController.h"
#import "TaskEditCell.h"

@interface ChooseGroupViewController (private)

- (void)reloadGroups:(NSArray *)newGroups;
- (void)refreshGroups;

@end


@implementation ChooseGroupViewController

@synthesize chooseGroupDataSource, groups, task, hasCachedData;

#pragma mark -
#pragma mark Initialisation

- (void)viewDidLoad 
{	
	[super viewDidLoad];
	
	 self.title = @"Choose Group";
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
	
	self.navigationItem.titleView = [[DefaultStyleSheet sharedDefaultStyleSheet] titleViewWithText:self.title];
	
	self.navigationItem.leftBarButtonItem = [[DefaultStyleSheet sharedDefaultStyleSheet] backItemWithText:@"Back"
																								   target:self.navigationController
																								 selector:@selector(customBackButtonTouched)];
	
}

- (void)setupDataSource
{
	[super setupDataSource];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:GroupsDidLoadNotification object:nil];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:GroupsDidLoadNotification];
	
	self.chooseGroupDataSource = [[[ChooseGroupDataSource alloc]init]autorelease];
	self.chooseGroupDataSource.tempTask = task;
	self.tableView.dataSource = self.chooseGroupDataSource;
	self.tableView.backgroundColor = [DefaultStyleSheet sharedDefaultStyleSheet].backgroundTexture;
	[self.tableView reloadData];
	
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
	[self.chooseGroupDataSource resetContent];
	
	self.groups = newGroups;
	if (self.groups.count > 0) {
		[self.chooseGroupDataSource.content addObjectsFromArray:self.groups];
	}
	
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark TableView Delegate

- (void)tableView:(UITableView *)aTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	CTXDOCellContext context = CTXDOCellContextTaskEditInput;
	
	if ([self isIndexPathSingleRow:indexPath]) {
		[(TaskEditCell *)cell setCellPosition:CTXDOCellPositionSingle context:context];
	} else if (indexPath.row == 0) {
		[(TaskEditCell *)cell setCellPosition:CTXDOCellPositionTop context:context];
	} else if ([self isIndexPathLastRow:indexPath]) {
		[(TaskEditCell *)cell setCellPosition:CTXDOCellPositionBottom context:context];
	} else {
		[(TaskEditCell *)cell setCellPosition:CTXDOCellPositionMiddle context:context];
	}
	
	cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	Group *group  = [self.chooseGroupDataSource groupForIndexPath:indexPath];
	
	self.task.groupId = group.groupId;
	self.task.groupName = group.name;
	
	[self.tableView reloadData];
	
	[self.navigationController popViewControllerAnimated:TRUE];
	
	[tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

#pragma mark -
#pragma mark Actions

- (void)refreshGroups
{
	NSArray *archivedContent = [[APIServices sharedAPIServices].groupsDict valueForKey:@"content"];
	self.hasCachedData = (archivedContent != nil);
	[self reloadGroups:archivedContent];
	
	[[APIServices sharedAPIServices]refreshGroups];
}

#pragma mark -
#pragma mark BaseLoadingViewCenter Delegate

- (void)baseLoadingViewCenterDidStartForKey:(NSString *)key
{
	if (self.hasCachedData) {
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
#pragma mark Dealloc

- (void)dealloc
{
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:GroupsDidLoadNotification];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[task release];
	[groups release];
	[chooseGroupDataSource release];
	
	[super dealloc];
}


@end
