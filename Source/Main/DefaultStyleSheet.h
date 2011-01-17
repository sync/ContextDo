#import <UIKit/UIKit.h>


@interface DefaultStyleSheet : NSObject {

}

+ (DefaultStyleSheet *)sharedDefaultStyleSheet;

@property (nonatomic, readonly) UIImage *navBarBackgroundImage;

- (UIBarButtonItem *)backItemWithText:(NSString *)text target:(id)target selector:(SEL)action;

- (UILabel *)titleViewWithText:(NSString *)text;

- (UIBarButtonItem *)navBarButtonItemWithText:(NSString *)text target:(id)target selector:(SEL)action;
- (UIBarButtonItem *)doneNavBarButtonItemWithText:(NSString *)text target:(id)target selector:(SEL)action;

- (UIBarButtonItem *)editBarButtonItemEditing:(BOOL)editing target:(id)target selector:(SEL)action;

@end
