#import <UIKit/UIKit.h>
#import "CustomNavigationBar.h"
#import "CustomToolbar.h"

@interface UINavigationController (Custom)

@property (nonatomic, readonly) CustomNavigationBar *customNavigationBar;
@property (nonatomic, readonly) CustomToolbar *customToolbar;

@end
