#import <UIKit/UIKit.h>


@interface CustomSearchBar : UISearchBar {

}

- (UIImage *)backgroundImageForStyle:(UIBarStyle)barStyle;
- (void)setBackgroundImage:(UIImage *)backgroundImage forBarStyle:(UIBarStyle)aBarStyle;
- (void)clearBackground;

- (void)setupCustomInitialisation;

@property(nonatomic) UIKeyboardAppearance keyboardAppearance;

@end
