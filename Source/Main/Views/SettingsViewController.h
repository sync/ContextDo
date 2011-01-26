#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import "SettingsDataSource.h"
#import "SettingsSliderView.h"

@interface SettingsViewController : BaseTableViewController {

}

@property (nonatomic, retain) SettingsDataSource *settingsDataSource;

- (IBAction)shouldLogout;

@property (nonatomic) CGFloat lastSliderValue;
@property (nonatomic, readonly) SettingsSliderView *settingsSliderView;

@end
