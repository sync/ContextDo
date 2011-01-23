#import <Foundation/Foundation.h>
#import "BaseTableViewController.h"
#import "TasksUpdatedDataSource.h"

@interface InfoViewController : BaseTableViewController {

}

@property (nonatomic, retain) IBOutlet UIButton *infoButton;

@property (nonatomic, retain) TasksUpdatedDataSource *tasksUpdatedDataSource;

@end
