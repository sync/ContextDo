#import <Foundation/Foundation.h>
#import "BaseTableViewController.h"
#import "TasksUpdatedDataSource.h"

@interface InfoViewController : BaseTableViewController {

}

@property (nonatomic, retain) TasksUpdatedDataSource *tasksUpdatedDataSource;

@property (nonatomic,  assign) UINavigationController *mainNavController;

@property (nonatomic) BOOL hasCachedData;

@end
