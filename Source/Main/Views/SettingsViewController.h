#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import "ChoicesListDataSource.h"

@interface SettingsViewController : BaseTableViewController {

}

@property (nonatomic, retain) ChoicesListDataSource *choicesListDataSource;

@end
