#import "CTXDODarkTextField.h"


@implementation CTXDODarkTextField


#pragma mark -
#pragma mark Init

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

#define TextSize 16.0

- (void)setupCustomInitialisation
{	
	UIImage *image = [UIImage imageNamed:@"inputfield_off.png"];
	image = [image stretchableImageWithLeftCapWidth:22 topCapHeight:0.0];
	
	self.font = [UIFont systemFontOfSize:TextSize];
	self.textColor = [UIColor colorWithHexString:@"7e7e82"];
	self.borderStyle = UITextBorderStyleNone;
	self.background = image;
	self.clearButtonMode = UITextFieldViewModeNever;
	self.rightViewMode = UITextFieldViewModeAlways;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
	CGRect rect = [super textRectForBounds:bounds];
	rect.origin.x = 10.0;
	rect.size.width = bounds.size.width - 2 * 10.0 - 54.0 - 5.0;
	return rect;
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
	CGRect rect = [super textRectForBounds:bounds];
	rect.origin.x = 10.0;
	rect.size.width = bounds.size.width - 2 * 10.0 - 54.0 - 5.0;
	return rect;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
	return CGRectMake(bounds.size.width - 54.0 - 10, (bounds.size.height - 28.0) / 2.0, 54.0, 28.0);
}

@end
