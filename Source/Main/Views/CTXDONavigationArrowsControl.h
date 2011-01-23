#import <UIKit/UIKit.h>


@interface CTXDONavigationArrowsControl : UIView {

}

- (void)addBackTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
- (void)addNextTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@property (nonatomic) BOOL canGoBack;
@property (nonatomic) BOOL canGoNext;

+ (id)navigationArrowsControl;

@end
