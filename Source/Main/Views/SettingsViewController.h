#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import "SettingsDataSource.h"

@interface SettingsViewController : BaseTableViewController {

}

@property (nonatomic, retain) SettingsDataSource *settingsDataSource;

- (IBAction)shouldLogout;

@end
