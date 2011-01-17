#import <UIKit/UIKit.h>


@interface DefaultStyleSheet : NSObject {

}

+ (DefaultStyleSheet *)sharedDefaultStyleSheet;

@property (nonatomic, readonly) UIImage *navBarBackgroundImage;

- (UIBarButtonItem *)backItemWithTitle:(NSString *)title target:(id)target selector:(SEL)action;

- (UILabel *)titleViewWithText:(NSString *)text;

@end
