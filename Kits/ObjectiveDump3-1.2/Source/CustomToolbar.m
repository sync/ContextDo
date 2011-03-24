#import "CustomToolbar.h"

@interface CustomToolbar () 

@property (nonatomic, readonly) NSMutableDictionary *backgroundImagesDict;
@property (nonatomic, readonly) NSMutableDictionary *shadowImagesDict;
- (void)setupShadow;
@property (nonatomic, readonly) UIImageView *shadowImageView;

@end

@implementation CustomToolbar

@synthesize backgroundImagesDict, shadowImagesDict, shadowImageView;

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
	self.clipsToBounds = FALSE;
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
#pragma mark ShadowImage

- (NSMutableDictionary *)shadowImagesDict
{
	if (!shadowImagesDict) {
		shadowImagesDict = [[NSMutableDictionary alloc]init];
	}
	
	return shadowImagesDict;
}

- (UIImageView *)shadowImageView
{
	if (!shadowImageView) {
		shadowImageView = [[[UIImageView alloc]initWithFrame:CGRectZero]autorelease];
		shadowImageView.userInteractionEnabled = FALSE;
		[self addSubview:shadowImageView];
	}
	
	return shadowImageView;
}

- (UIImage *)shadowImageForStyle:(UIBarStyle)aBarStyle
{
	return [self.shadowImagesDict objectForKey:[NSNumber numberWithInteger:aBarStyle]];
}

- (void)setShadowImage:(UIImage *)shadowImage forBarStyle:(UIBarStyle)aBarStyle;
{
	if (shadowImage) {
		[self.shadowImagesDict setObject:shadowImage forKey:[NSNumber numberWithInteger:aBarStyle]];
	} else {
		[self.shadowImagesDict removeObjectForKey:[NSNumber numberWithInteger:aBarStyle]];
	}
	
	[self setupShadow];
}

- (void)clearShadow
{
	[self.shadowImagesDict removeAllObjects];
	[self setupShadow];
}

#pragma mark -
#pragma mark Drawing

- (void)setupShadow
{
	UIImage *shadowImage = [self shadowImageForStyle:self.barStyle];
	if (shadowImage) {
		CGSize boundsSize = self.bounds.size;
		CGRect rect = CGRectMake(0.0, 
								 -shadowImage.size.height,
								 boundsSize.width,
								 shadowImage.size.height);
		self.shadowImageView.image = shadowImage;
		self.shadowImageView.frame = rect;
	}
}

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
#pragma mark Dealloc

- (void)dealloc 
{
	[shadowImagesDict release];
	[backgroundImagesDict release];
	
    [super dealloc];
}

@end
