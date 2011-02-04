#import "CTXDONavigationArrowsControl.h"

@interface CTXDONavigationArrowsControl ()

- (void)setupCustomInitialisation;

@property (nonatomic, readonly) UIButton *backButton;
@property (nonatomic, readonly) UIButton *nextButton;

@end


@implementation CTXDONavigationArrowsControl

@synthesize backButton, nextButton, canGoBack, canGoNext;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		// Custom initialization
		[self setupCustomInitialisation];
    }
    return self;
}

// The designated initializer. Override to perform setup that is required before the view is loaded.
// Only when using xib (interface buildder)
- (id)initWithCoder:(NSCoder *)decoder {
	self = [super initWithCoder:decoder];
    if (self) {
		// Custom initialization
		[self setupCustomInitialisation];
	}
	return self;
}

- (void)setupCustomInitialisation
{
	// Initialization code
	self.backgroundColor = [UIColor clearColor];
	
	[self addSubview:self.backButton];
	[self addSubview:self.nextButton];
}

+ (id)navigationArrowsControl
{
	UIImage *image = [UIImage imageNamed:@"btn_tbar_dwnarrow_off.png"];
	CTXDONavigationArrowsControl *control = [[[CTXDONavigationArrowsControl alloc]initWithFrame:CGRectMake(0.0,
																										   0.0,
																										   image.size.width * 2.0,
																										   image.size.height)]autorelease];
	return control;
}

- (UIButton *)backButton
{
	if (!backButton) {
		backButton = [[UIButton buttonWithType:UIButtonTypeCustom]retain];
		[backButton setBackgroundImage:[UIImage imageNamed:@"btn_tbar_uparrow_off.png"] forState:UIControlStateNormal];
		[backButton setBackgroundImage:[UIImage imageNamed:@"btn_tbar_uparrow_touch.png"] forState:UIControlStateHighlighted];
	}
	
	return backButton;
}

- (UIButton *)nextButton
{
	if (!nextButton) {
		nextButton = [[UIButton buttonWithType:UIButtonTypeCustom]retain];
		[nextButton setBackgroundImage:[UIImage imageNamed:@"btn_tbar_dwnarrow_off.png"] forState:UIControlStateNormal];
		[nextButton setBackgroundImage:[UIImage imageNamed:@"btn_tbar_dwnarrow_touch.png"] forState:UIControlStateHighlighted];
	}
	
	return nextButton;
}

- (void)addBackTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
	[self.backButton addTarget:target action:action forControlEvents:controlEvents]; 
}

- (void)addNextTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
	[self.nextButton addTarget:target action:action forControlEvents:controlEvents]; 
}

- (void)setCanGoBack:(BOOL)aCanGoBack
{
	canGoBack = aCanGoBack;
	self.backButton.enabled = aCanGoBack;
}

- (void)setCanGoNext:(BOOL)aCanGoNext
{
	canGoNext = aCanGoNext;
	self.nextButton.enabled = aCanGoNext;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	
	self.backButton.frame = CGRectMake(0.0,
									   0.0,
									   self.bounds.size.width / 2.0,
									   self.bounds.size.height);
	
	self.nextButton.frame = CGRectMake(self.bounds.size.width / 2.0,
										0.0,
										self.bounds.size.width / 2.0,
										self.bounds.size.height);
}

@end
