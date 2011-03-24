#import "AccessoryViewWithImage.h"


@implementation AccessoryViewWithImage

@synthesize leftRightDiff;

#pragma mark -
#pragma mark Initialization

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
	self.backgroundColor = [UIColor clearColor];
	self.leftRightDiff = 0.0;
}

- (UIImageView *)imageView
{
	if (!_imageView) {
		_imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
		[self addSubview:_imageView];
	}
	return _imageView;
}

- (void)setleftRightDiff:(CGFloat)aLeftRightDiff
{
	if (leftRightDiff != aLeftRightDiff) {
		leftRightDiff = aLeftRightDiff;
		[self setNeedsLayout];
	}
}

+(id)accessoryViewWithImageNamed:(NSString *)imageNamed highlightedImageNamed:(NSString *)highlightedImageNamed cellHeight:(CGFloat)cellHeight
{
	AccessoryViewWithImage *accessoryView = [[[AccessoryViewWithImage alloc]initWithFrame:CGRectZero]autorelease];
	UIImage *image = [UIImage imageNamed:imageNamed];
	accessoryView.frame = CGRectIntegral(CGRectMake(accessoryView.frame.origin.x - image.size.width, accessoryView.frame.origin.y, image.size.width + (accessoryView.leftRightDiff * 2.0), cellHeight));
	accessoryView.imageView.image = image;
	accessoryView.imageView.highlightedImage = [UIImage imageNamed:highlightedImageNamed];
	return accessoryView;
}

+(id)accessoryViewWithImageNamed:(NSString *)imageNamed highlightedImageNamed:(NSString *)highlightedImageNamed cellHeight:(CGFloat)cellHeight leftRightDiff:(CGFloat)leftRightDiff
{
	AccessoryViewWithImage *accessoryView = [[[AccessoryViewWithImage alloc]initWithFrame:CGRectZero]autorelease];
	UIImage *image = [UIImage imageNamed:imageNamed];
	accessoryView.leftRightDiff = leftRightDiff;
	accessoryView.frame = CGRectIntegral(CGRectMake(accessoryView.frame.origin.x - image.size.width, accessoryView.frame.origin.y, image.size.width + (accessoryView.leftRightDiff * 2.0), cellHeight));
	accessoryView.imageView.image = image;
	accessoryView.imageView.highlightedImage = [UIImage imageNamed:highlightedImageNamed];
	return accessoryView;
}


- (void)layoutSubviews
{
	[super layoutSubviews];
	
	if (self.imageView.image) {
		CGRect rect = self.bounds;
		self.imageView.frame = CGRectIntegral(CGRectMake((rect.size.width - self.imageView.image.size.width) / 2.0, 
														 (rect.size.height - self.imageView.image.size.height) / 2.0, 
														 self.imageView.image.size.width, 
														 self.imageView.image.size.height));
	}
}


- (void)dealloc 
{
    [_imageView release];
	
	[super dealloc];
}



@end
