#import "CTXDODarkTextField.h"

@implementation CTXDODarkTextField

#pragma mark -
#pragma mark Init

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
	[self updateBackgroundImage];
	
	self.font = [UIFont systemFontOfSize:TextSize];
	self.textColor = [UIColor colorWithHexString:@"7e7e82"];
	self.borderStyle = UITextBorderStyleNone;
	
	self.clearButtonMode = UITextFieldViewModeWhileEditing;
	self.rightViewMode = UITextFieldViewModeAlways;
	
	self.keyboardAppearance = UIKeyboardAppearanceAlert;
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
	CGRect rect = [super editingRectForBounds:bounds];
	rect.origin.x = 10.0;
	rect.size.width = bounds.size.width - 2 * 10.0 - 54.0 - 5.0;
	return rect;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
	return CGRectMake(bounds.size.width - 54.0 - 10, (bounds.size.height - 28.0) / 2.0, 54.0, 28.0);
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds
{
	CGRect rect = [super clearButtonRectForBounds:bounds];
	rect.origin.x = bounds.size.width - rect.size.width - 10.0;
	return rect;
}

#pragma mark -
#pragma mark Background

- (void)updateBackgroundImage 
{
	UIImage *image = nil;
	if (!self.editing) {
		image = [UIImage imageNamed:@"inputfield_off.png"];
	} else {
		image = [UIImage imageNamed:@"inputfield_touch.png"];
	}
	image = [image stretchableImageWithLeftCapWidth:(image.size.width / 2.0) - 1.0 topCapHeight:0.0];
	
	if (![image isEqual:self.background]) {
		self.background = image;
	}
}

@end
