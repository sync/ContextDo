#import "CTXDOTableHeaderView.h"

@implementation CTXDOTableHeaderView

@synthesize textLabel;


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

- (void)setupCustomInitialisation {
	self.backgroundColor = [UIColor clearColor];
}

#define FontSize 16.0

- (UILabel *)textLabel
{
	if (!textLabel) {
		textLabel = [[[UILabel alloc]initWithFrame:CGRectZero]autorelease];
		textLabel.font = [UIFont systemFontOfSize:FontSize];
		textLabel.textColor = [UIColor colorWithHexString:@"515053"];
		textLabel.shadowOffset = CGSizeMake(0,-1);
		textLabel.shadowColor = [UIColor colorWithHexString:@"00000040"];
		textLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:textLabel];
	}
	
	return textLabel;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGSize boundsSize = self.bounds.size;
	
#define LeftRightDiff 25.0
#define BottomDiff 5.0
	[self.textLabel sizeToFit];
	self.textLabel.frame = CGRectMake(LeftRightDiff,
									  boundsSize.height - self.textLabel.frame.size.height - BottomDiff,
									  boundsSize.width - 2 * LeftRightDiff,
									  self.textLabel.frame.size.height);
}


@end
