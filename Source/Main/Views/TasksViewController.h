#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import "TasksDataSource.h"


@interface TasksViewController : BaseTableViewController <UISearchBarDelegate> {

}

@property (nonatomic, retain) TasksDataSource *tasksDataSource;
@property (nonatomic, retain) TasksDataSource *searchTasksDataSource;

@property (nonatomic, readonly) NSMutableArray *tasks;

@property (nonatomic, retain) Group *group;

@property (nonatomic, readonly) BOOL isTodayTasks;

@property (nonatomic, retain) IBOutlet CustomSearchBar *searchBar;

@property (nonatomic, copy) NSArray *tasksSave;

@property (nonatomic,  assign) UINavigationController *mainNavController;

- (void)refreshTasks;

@end
