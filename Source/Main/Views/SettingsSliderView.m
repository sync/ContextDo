#import "SettingsSliderView.h"


@implementation SettingsSliderView

@synthesize slider;

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

- (void)setupCustomInitialisation
{	
	self.backgroundColor = [UIColor clearColor];
}

- (CTXDoSlider *)slider
{
	if (!slider) {
		slider = [[[CTXDoSlider alloc]initWithFrame:CGRectZero]autorelease];
		[self addSubview:slider];
	}
	
	return slider;
}

#define SliderLeftRigthDiff 25.0
#define SliderHeight 22.0
#define SliderTopDiff 25.0
#define AdjustLeftDiff 5.0

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGSize boundsSize = self.bounds.size;
	
	self.slider.frame = CGRectMake(SliderLeftRigthDiff + AdjustLeftDiff, SliderTopDiff, boundsSize.width - 2 * SliderLeftRigthDiff, SliderHeight);
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSaveGState(ctx);
	
	[[UIColor colorWithHexString:@"929092"]set];
	
	CGContextSetShadowWithColor(ctx, CGSizeMake(0,-1), 0.5, [[UIColor colorWithHexString:@"00000040"] CGColor]);
	
	NSArray *legends = [NSArray arrayWithObjects:
						@"100m",
						@"500m",
						@"1km",
						@"3km",
						@"5km",
						nil];
	
	CGSize boundsSize = self.bounds.size;
	
#define LegendDiff ((boundsSize.width - 2 * SliderLeftRigthDiff) / 4.0)
#define LegendLeftRightDiff 5.0	
#define SliderLegendDiff 7.0
	
	NSInteger i = 0;
	for (NSString *legend in legends) {
		[legend drawAtPoint:CGPointMake(SliderLeftRigthDiff + LegendLeftRightDiff + i * LegendDiff - i * LegendLeftRightDiff, SliderTopDiff + SliderHeight + SliderLegendDiff) withFont:[UIFont boldSystemFontOfSize:11.0]];
		i++;
	}
	
	CGContextRestoreGState(ctx);
}

@end
