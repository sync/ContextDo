#import "BaseTableViewController.h"


@implementation BaseTableViewController

@synthesize tableView, searchString;

#pragma mark -
#pragma mark Initialisation

// The designated initializer. Override to perform setup that is required before the view is loaded.
// Only when xibless (interface buildder)
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Custom initialization
		[self setupCustomInitialisation];
	}
	return self;
}

// The designated initializer. Override to perform setup that is required before the view is loaded.
// Only when using xib (interface buildder)
- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		// Custom initialization
		[self setupCustomInitialisation];
	}
	return self;
}

- (void)setupCustomInitialisation
{
	
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	[self setupDataSource];
	[self setupSearchDataSource];
}

#pragma mark -
#pragma mark Setup

- (void)setupDataSource
{
	
}

- (void)setupSearchDataSource
{	
	
}

#pragma mark -
#pragma mark tableView Delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	
	[aTableView deselectRowAtIndexPath:indexPath animated:TRUE];
	
}

#pragma mark -
#pragma mark Content reloading

- (void)shouldReloadContent:(NSNotification *)notification
{
	[super shouldReloadContent:notification];
	
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark  UISearchDisplayDelegate

// return YES to reload table. called when search string/option changes. convenience methods on top UISearchBar delegate methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)aSearchString
{
	if ([aSearchString isEqualToString:self.searchString]) {
		return FALSE;
	}
	self.searchString = aSearchString;
	[self filterContentForSearchText:aSearchString scope:
	 [[controller.searchBar scopeButtonTitles] objectAtIndex:[controller.searchBar selectedScopeButtonIndex]]];
	return TRUE;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
	self.searchString = nil;
}

#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[self.searchDisplayController.searchResultsTableView reloadData];
}

#pragma mark -
#pragma mark Memory

- (void)viewDidUnload {
	[super viewDidUnload];
	
	self.tableView = nil;
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


- (void)dealloc {
	[tableView release];
	[searchString release];
	
    [super dealloc];
}

@end
