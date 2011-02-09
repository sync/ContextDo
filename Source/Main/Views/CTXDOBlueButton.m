#import "CTXDOBlueButton.h"


@implementation CTXDOBlueButton

// The designated initializer. Override to perform setup that is required before the view is loaded.
// Only when xibless (interface buildder)
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

#pragma mark -
#pragma mark Setup

#define TextSize 16.0

- (void)setupCustomInitialisation
{	
	self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	
	UIImage *image = [UIImage imageNamed:@"btn_fb_off.png"];
	image = [image stretchableImageWithLeftCapWidth:(image.size.width / 2.0) - 1.0 topCapHeight:0.0];
	[self setBackgroundImage:image forState:UIControlStateNormal];
	
	UIImage *highlightedImage = [UIImage imageNamed:@"btn_fb_touch.png"];
	highlightedImage = [highlightedImage stretchableImageWithLeftCapWidth:(highlightedImage.size.width / 2.0) - 1.0 topCapHeight:0.0];
	[self setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
	
	self.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
	[self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
	self.titleLabel.shadowOffset = CGSizeMake(0,-1);
	[self setTitleShadowColor:[UIColor colorWithHexString:@"00000040"] forState:UIControlStateNormal];
	[self setTitleShadowColor:[UIColor colorWithHexString:@"00000040"] forState:UIControlStateHighlighted];
}


@end
