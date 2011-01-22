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

@property (nonatomic, readonly) UIImage *toolbarBackgroundImage;

- (UIBarButtonItem *)buttonItemWithImageNamed:(NSString *)imageNamed highlightedImageNamed:(NSString *)highlightedImageNamed target:(id)target selector:(SEL)action;

@property (nonatomic, readonly) UIImageView *darkBackgroundTextureView;
@property (nonatomic, readonly) UIColor *backgroundTexture;

- (UIButton *)inputTextFieldButtonWithText:(NSString *)text target:(id)target selector:(SEL)action;

@property (nonatomic, readonly) UIColor *blackedOutColor;

@end
