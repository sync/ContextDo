#import <UIKit/UIKit.h>

// some ideas from:
// http://stackoverflow.com/questions/1869331/set-programmatically-a-custom-subclass-of-uinavigationbar-in-uinavigationcontroll
// some code from:
// http://idevrecipes.com/2011/01/12/how-do-iphone-apps-instagramreederdailybooth-implement-custom-navigationbar-with-variable-width-back-buttons/

@interface CustomNavigationBar : UINavigationBar {

}

- (UIImage *)backgroundImageForStyle:(UIBarStyle)barStyle;
- (void)setBackgroundImage:(UIImage *)backgroundImage forBarStyle:(UIBarStyle)aBarStyle;
- (void)clearBackground;

+ (UIButton *)customBackButtonForBackgroundImage:(UIImage*)backgroundImage 
								highlightedImage:(UIImage*)highlightedImage 
									leftCapWidth:(CGFloat)leftCapWidth
										   title:(NSString *)title
											font:(UIFont *)font;

- (void)setupCustomInitialisation;

@end
