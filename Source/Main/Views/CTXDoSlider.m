#import "CTXDoSlider.h"


@implementation CTXDoSlider


// The designated initializer. Override to perform setup that is required before the view is loaded.
// Only when xibless (interface buildder)
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Custom initialization
		[self setupCustomInitialisation];
    }
    return self;
}

// The designated initializer. Override to perform setup that is required before the view is loaded.
// Only when using xib (interface buildder)
- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		// Custom initialization
		[self setupCustomInitialisation];
	}
	return self;
}

#pragma mark -
#pragma mark Setup

- (void)setupCustomInitialisation
{	
	[self setThumbImage:[UIImage imageNamed:@"UISliderHandle.png"] forState:UIControlStateNormal];
	[self setThumbImage:[UIImage imageNamed:@"UISliderHandleDown.png"] forState:UIControlStateHighlighted];
	
	UIImage *minTrack = [UIImage imageNamed:@"UISliderBlue.png"];
	minTrack = [minTrack stretchableImageWithLeftCapWidth:(minTrack.size.width / 2.0) - 1.0 topCapHeight:0.0];
	[self setMinimumTrackImage:minTrack forState:UIControlStateNormal];
	[self setMinimumTrackImage:minTrack forState:UIControlStateNormal];
	
	UIImage *maxTrack = [UIImage imageNamed:@"UISliderWhite.png"];
	maxTrack = [maxTrack stretchableImageWithLeftCapWidth:(maxTrack.size.width / 2.0) - 1.0 topCapHeight:0.0];
	[self setMaximumTrackImage:maxTrack forState:UIControlStateNormal];
	[self setMaximumTrackImage:maxTrack forState:UIControlStateNormal];
}

@end
