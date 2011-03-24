#import <UIKit/UIKit.h>


@interface AccessoryViewWithImage : UIView {
	UIImageView *_imageView;
}

@property (nonatomic, readonly) UIImageView *imageView;
@property (nonatomic)  CGFloat leftRightDiff;

+(id)accessoryViewWithImageNamed:(NSString *)imageNamed highlightedImageNamed:(NSString *)highlightedImageNamed cellHeight:(CGFloat)cellHeight;
+(id)accessoryViewWithImageNamed:(NSString *)imageNamed highlightedImageNamed:(NSString *)highlightedImageNamed cellHeight:(CGFloat)cellHeight leftRightDiff:(CGFloat)leftRightDiff;

- (void)setupCustomInitialisation;

@end
