#import <Foundation/Foundation.h>
#import "BaseTableViewController.h"
#import "ChooseGroupDataSource.h"

@interface ChooseGroupViewController : BaseTableViewController {

}

@property (nonatomic, retain) ChooseGroupDataSource *chooseGroupDataSource;

@property (nonatomic, readonly) NSMutableArray *groups;

@property (nonatomic, retain) Task *task;

@end
