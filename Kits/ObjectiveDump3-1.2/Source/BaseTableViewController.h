#import <Foundation/Foundation.h>
#import "BaseViewController.h"

@interface BaseTableViewController : BaseViewController <UITableViewDelegate, UISearchDisplayDelegate> {
	
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
- (void)setupDataSource;

- (BOOL)isIndexPathLastRow:(NSIndexPath *)indexPath;
- (BOOL)isIndexPathSingleRow:(NSIndexPath *)indexPath;

// Content Filtering
@property (nonatomic, retain) NSString *searchString;
- (void)setupSearchDataSource;
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;

@end
