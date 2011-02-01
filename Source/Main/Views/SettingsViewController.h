#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import "SettingsDataSource.h"
#import "SettingsSliderView.h"
#import "CTXDOButton.h"

@interface SettingsViewController : BaseTableViewController {

}

@property (nonatomic, retain) SettingsDataSource *settingsDataSource;

@property (nonatomic, retain) IBOutlet CTXDOButton *fbButton;

- (IBAction)shouldLogout;
- (IBAction)shouldFacebookConnect;

@property (nonatomic) CGFloat lastSliderValue;
@property (nonatomic, readonly) SettingsSliderView *settingsSliderView;

@property (nonatomic, readonly) BOOL isFacebookConnected;

@end
