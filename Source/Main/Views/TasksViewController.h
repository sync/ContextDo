#import <UIKit/UIKit.h>
#import "CTXDOTableViewRefreshController.h"
#import "TasksDataSource.h"


@interface TasksViewController : CTXDOTableViewRefreshController <UISearchBarDelegate> {

}

@property (nonatomic, retain) TasksDataSource *tasksDataSource;

@property (nonatomic, retain) NSArray *tasks;
@property (nonatomic, retain) Group *group;
@property (nonatomic, retain) NSArray *tasksSave;

@property (nonatomic, readonly) BOOL isTodayTasks;
@property (nonatomic, readonly) BOOL isNearTasks;

@property (nonatomic, retain) IBOutlet CustomSearchBar *searchBar;

@property (nonatomic,  assign) UINavigationController *mainNavController;

- (void)refreshTasks;
- (void)reloadTasks:(NSArray *)newTasks;

@end
