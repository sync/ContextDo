#import <Foundation/Foundation.h>
#import "BaseViewController.h"

@interface BaseTableViewController : BaseViewController <UITableViewDelegate, UISearchDisplayDelegate> {
	
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
- (void)setupDataSource;

// Content Filtering
@property (nonatomic, copy) NSString *searchString;
- (void)setupSearchDataSource;
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;

@end
