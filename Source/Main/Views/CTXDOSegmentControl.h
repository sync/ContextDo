#import <UIKit/UIKit.h>


@interface CTXDOSegmentControl : UIView <UIGestureRecognizerDelegate> {
	
}

@property (nonatomic, retain) NSArray *segments;
@property (nonatomic) NSInteger selectedSegmentIndex;
@property (nonatomic, assign) id target;
@property SEL action;
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@property (nonatomic, retain) UITapGestureRecognizer *gestureRecognizer;

- (CGRect)leftRect;
- (CGRect)middleRect;
- (CGRect)rightRect;

+ (id)segmentedControlWithItems:(NSArray *)items;

- (void)setupCustomInitialisation;

@end
