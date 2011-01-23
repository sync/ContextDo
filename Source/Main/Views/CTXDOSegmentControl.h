#import <UIKit/UIKit.h>


@interface CTXDOSegmentControl : UIView <UIGestureRecognizerDelegate> {
	
}

@property (nonatomic, retain) NSArray *segments;
@property (nonatomic) NSInteger selectedSegmentIndex;

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

+ (id)segmentedControlWithItems:(NSArray *)items;

@end
