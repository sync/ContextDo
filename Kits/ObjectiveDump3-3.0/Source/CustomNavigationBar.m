#import "CustomNavigationBar.h"

@interface CustomNavigationBar () 

@property (nonatomic, readonly) NSMutableDictionary *backgroundImagesDict;

@end

@implementation CustomNavigationBar

@synthesize backgroundImagesDict;

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

- (void)setupCustomInitialisation
{
	// Initialization code
	// Nothing
}

#pragma mark -
#pragma mark BackgroundImage

- (NSMutableDictionary *)backgroundImagesDict
{
	if (!backgroundImagesDict) {
		backgroundImagesDict = [[NSMutableDictionary alloc]init];
	}
	
	return backgroundImagesDict;
}

- (UIImage *)backgroundImageForStyle:(UIBarStyle)aBarStyle
{
	return [self.backgroundImagesDict objectForKey:[NSNumber numberWithInteger:aBarStyle]];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage forBarStyle:(UIBarStyle)aBarStyle;
{
	if (backgroundImage) {
		[self.backgroundImagesDict setObject:backgroundImage forKey:[NSNumber numberWithInteger:aBarStyle]];
	} else {
		[self.backgroundImagesDict removeObjectForKey:[NSNumber numberWithInteger:aBarStyle]];
	}
	
	[self setNeedsDisplay];
}

- (void)clearBackground
{
	[self.backgroundImagesDict removeAllObjects];
	[self setNeedsDisplay];
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(CGRect)rect 
{
    // Drawing code.
	UIImage *backgroundImage = [self backgroundImageForStyle:self.barStyle];
	if (backgroundImage) {
		[backgroundImage drawInRect:rect];
	} else {
		[super drawRect:rect];
	}
}

#pragma mark -
#pragma mark BackButton

// Given the prpoer images and cap width, create a variable width back button
+ (UIButton *)customBackButtonForBackgroundImage:(UIImage*)backgroundImage 
								highlightedImage:(UIImage*)highlightedImage 
									leftCapWidth:(CGFloat)leftCapWidth
										   title:(NSString *)title
											font:(UIFont *)font
{
	backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:0.0];
	highlightedImage = [highlightedImage stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:0.0];

	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	
	button.titleEdgeInsets = UIEdgeInsetsMake(0, leftCapWidth, 0, 3.0);
	button.titleLabel.font = (font) ? font : [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	button.titleLabel.shadowOffset = CGSizeMake(0,-1);
	[button setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
	button.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
	
	[button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
	[button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
	
	CGSize textSize = [title sizeWithFont:button.titleLabel.font];
	button.frame = CGRectMake(button.frame.origin.x, 
							  button.frame.origin.y, 
							  textSize.width + leftCapWidth + 3.0 + 5.0, 
							  backgroundImage.size.height);
	
	[button setTitle:title forState:UIControlStateNormal];
	
	return button;
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc 
{
	[backgroundImagesDict release];
	
    [super dealloc];
}


@end
