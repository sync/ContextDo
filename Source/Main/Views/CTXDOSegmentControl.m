#import "CTXDOSegmentControl.h"

@interface CTXDOSegmentControl ()

- (CGRect)leftRect;
- (CGRect)middleRect;
- (CGRect)rightRect;

@property (nonatomic, assign) id target;
@property SEL action;

@property (nonatomic, retain) UITapGestureRecognizer *gestureRecognizer;

- (void)setupCustomInitialisation;


@end


@implementation CTXDOSegmentControl

@synthesize segments, selectedSegmentIndex;
@synthesize target, action, gestureRecognizer;

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
	self.selectedSegmentIndex = 0;
	
	self.gestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]autorelease];
	self.gestureRecognizer.delegate = self;
	[self addGestureRecognizer:self.gestureRecognizer];
	
}

+ (id)segmentedControlWithItems:(NSArray *)items
{
	CTXDOSegmentControl *segmentedControl = [[[CTXDOSegmentControl alloc]initWithFrame:CGRectZero]autorelease];
	segmentedControl.segments = items;
	return segmentedControl;
}

- (void)addTarget:(id)aTarget action:(SEL)aAction forControlEvents:(UIControlEvents)controlEvents
{
	self.target = aTarget;
	self.action = aAction;
}

- (void)setSegments:(NSArray *)newSegments
{
	[segments release];
	segments = [newSegments retain];
	[self setNeedsDisplay];
}

- (void)setSelectedSegmentIndex:(NSInteger)index
{
	if (index != selectedSegmentIndex) {
		selectedSegmentIndex = index;
		[self setNeedsDisplay];
		[self.target performSelector:self.action withObject:self];
	}
}

- (CGRect)leftRect
{
	return CGRectMake(0.0, 0.0, self.bounds.size.width/3, self.bounds.size.height);
}

- (CGRect)middleRect
{
	return CGRectMake(self.bounds.size.width/3, 0.0, self.bounds.size.width/3, self.bounds.size.height);
}

- (CGRect)rightRect
{
	return CGRectMake(self.bounds.size.width/3 * 2, 0.0, self.bounds.size.width/3, self.bounds.size.height);
}

- (void)handleGesture:(UIGestureRecognizer *)aGestureRecognizer;
{
	CGPoint currentTouchPosition = [aGestureRecognizer locationInView:self]; 
	if (currentTouchPosition.x <= self.bounds.size.width/3) {
		self.selectedSegmentIndex = 0;
		return;
	} else if (currentTouchPosition.x <= self.bounds.size.width/3 * 2) {
		self.selectedSegmentIndex = 1;
		return;
	}
	
	self.selectedSegmentIndex = 2;
	
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
	// Font
#define FontSize 14.0
	UIFont *normalFont = [UIFont systemFontOfSize:FontSize];
	UIFont *boldFont = [UIFont boldSystemFontOfSize:FontSize];
	// Color
	UIColor *normalColor = [UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1.0];
	[normalColor set];
	
	UIImage *backgroundImage = nil;
	if (self.selectedSegmentIndex == 0) {
		backgroundImage = [UIImage imageNamed:@"taskdetails_tab_lefton.png"];
		[backgroundImage drawInRect:rect];
	} else if (self.selectedSegmentIndex == 1) {
		backgroundImage = [UIImage imageNamed:@"taskdetails_tab_midon.png"];
		[backgroundImage drawInRect:rect];
	} else {
		backgroundImage = [UIImage imageNamed:@"taskdetails_tab_righton.png"];
		[backgroundImage drawInRect:rect];
	}
	
#define BottomDiff 10.0
#define FontHeight (FontSize + 4.0)
#define FontY ((self.bounds.size.height -BottomDiff - FontHeight) / 2.0)
	
	// Left part
	NSString *leftText = [self.segments objectAtIndex:0];
	[leftText drawInRect:CGRectMake(0.0, 
									FontY, 
									self.bounds.size.width/3,
									FontHeight) 
				withFont:(self.selectedSegmentIndex == 0) ? boldFont : normalFont
		   lineBreakMode:UILineBreakModeTailTruncation 
			   alignment:UITextAlignmentCenter];
	// Midlle part
	NSString *middleText = [self.segments objectAtIndex:1];
	[middleText drawInRect:CGRectMake(self.bounds.size.width/3,
									  FontY, 
									  self.bounds.size.width/3,
									  FontHeight) 
				  withFont:(self.selectedSegmentIndex == 10) ? boldFont : normalFont 
			 lineBreakMode:UILineBreakModeTailTruncation 
				 alignment:UITextAlignmentCenter];
	// Right part
	NSString *rightText = [self.segments objectAtIndex:2];
	[rightText drawInRect:CGRectMake(self.bounds.size.width/3 * 2, 
									 FontY, 
									 self.bounds.size.width/3,
									 FontHeight) 
				 withFont:(self.selectedSegmentIndex == 2) ? boldFont : normalFont 
			lineBreakMode:UILineBreakModeTailTruncation 
				alignment:UITextAlignmentCenter];
}

- (void)dealloc 
{
	[gestureRecognizer release];
	[segments release];
	
	[super dealloc];
}

@end
