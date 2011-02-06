#import <UIKit/UIKit.h>

// some ideas from:
// http://stackoverflow.com/questions/1869331/set-programmatically-a-custom-subclass-of-uinavigationbar-in-uinavigationcontroll
// some code from:
// http://idevrecipes.com/2011/01/12/how-do-iphone-apps-instagramreederdailybooth-implement-custom-navigationbar-with-variable-width-back-buttons/

@interface CustomToolbar : UIToolbar {

}

- (UIImage *)backgroundImageForStyle:(UIBarStyle)barStyle;
- (void)setBackgroundImage:(UIImage *)backgroundImage forBarStyle:(UIBarStyle)aBarStyle;
- (void)clearBackground;

- (UIImage *)shadowImageForStyle:(UIBarStyle)barStyle;
- (void)setShadowImage:(UIImage *)shadowImage forBarStyle:(UIBarStyle)aBarStyle;
- (void)clearShadow;

- (void)setupCustomInitialisation;

@end
