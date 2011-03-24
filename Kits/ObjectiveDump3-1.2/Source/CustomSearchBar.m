#import "CustomSearchBar.h"

@interface CustomSearchBar () 

@property (nonatomic, readonly) NSMutableDictionary *backgroundImagesDict;
@property (nonatomic, readonly) UIView *customBackgroundView;

@end


@implementation CustomSearchBar

@synthesize backgroundImagesDict;

#pragma mark - Init

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
	
	[self layoutSubviews];
}

- (void)clearBackground
{
	[self.backgroundImagesDict removeAllObjects];
	[self layoutSubviews];
}

#pragma mark - Background hax

- (UIView *)customBackgroundView
{
    NSString *stringClass = [NSString stringWithFormat:@"UISearchBar%@", @"Background"];
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:NSClassFromString(stringClass)]) {
            return view;
        }
    }
    return nil;
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

- (void)layoutSubviews{
    [super layoutSubviews];
    
    UIImage *backgroundImage = [self backgroundImageForStyle:self.barStyle];
	self.customBackgroundView.hidden = (backgroundImage != nil);
}

#pragma mark - Keyboard

- (UIKeyboardAppearance)keyboardAppearance
{
	for(UIView *subView in self.subviews) {
		if([subView isKindOfClass: [UITextField class]]) {
			return [(UITextField *)subView keyboardAppearance];
		}
	}
	
	return UIKeyboardAppearanceDefault;
}	

- (void)setKeyboardAppearance:(UIKeyboardAppearance)keyboardAppearance
{
	for(UIView *subView in self.subviews) {
		if([subView isKindOfClass: [UITextField class]]) {
			[(UITextField *)subView setKeyboardAppearance: UIKeyboardAppearanceAlert];
		}
	}
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc 
{
	[backgroundImagesDict release];
	
    [super dealloc];
}

@end
