#import "CellBackgroundView.h"


@implementation CellBackgroundView

@synthesize cellPosition, cellContext;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		self.cellPosition = CTXDOCellPositionSingle;
		self.opaque = FALSE;
    }
    return self;
}

- (void)setCellPosition:(CTXDOCellPosition)aCellPosition context:(CTXDOCellContext)aCellContext
{
	self.cellPosition = aCellPosition;
	self.cellContext = aCellContext;
	[self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	BOOL drawTop = FALSE;
	BOOL drawBottom = FALSE;
	BOOL drawSeparator = FALSE;
	if (self.cellPosition == CTXDOCellPositionSingle) {
		drawTop = TRUE;
		drawBottom = TRUE;
	} else if (self.cellPosition == CTXDOCellPositionTop) {
		drawTop = TRUE;
		drawSeparator = TRUE;
	} else if (self.cellPosition == CTXDOCellPositionMiddle) {
		drawSeparator = TRUE;
	} else if (self.cellPosition == CTXDOCellPositionBottom) {
		drawBottom = TRUE;
	}
	
	NSString *topImageNamed = nil;
	NSString *middleImageNamed = nil;
	NSString *bottomImageNamed = nil;
	if (self.cellContext == CTXDOCellContextStandard) {
		topImageNamed = @"table_std_top.png";
		middleImageNamed = @"table_std_mid.png";
		bottomImageNamed = @"table_std_bot.png";
	} else if (self.cellContext == CTXDOCellContextExpiring) {
		topImageNamed = @"table_exp_top.png";
		middleImageNamed = @"table_exp_mid.png";
		bottomImageNamed = @"table_exp_bot.png";
	} else if (self.cellContext == CTXDOCellContextLocationAware) {
		topImageNamed = @"table_loc_top.png";
		middleImageNamed = @"table_loc_mid.png";
		bottomImageNamed = @"table_loc_bot.png";
	} else if (self.cellContext == CTXDOCellContextDue) {
		topImageNamed = @"table_due_top.png";
		middleImageNamed = @"table_due_mid.png";
		bottomImageNamed = @"table_due_bot.png";
	} else if (self.cellContext == CTXDOCellContextDueToday) {
		topImageNamed = @"table_info_top.png";
		middleImageNamed = @"table_info_mid.png";
		bottomImageNamed = @"table_info_bot.png";
	}
	
	CGSize boundsSize = self.bounds.size;
	
	CGFloat topHeight = 0.0;
	
	if (drawTop) {
		UIImage *topImage = [UIImage imageNamed:topImageNamed];
		topImage = [topImage stretchableImageWithLeftCapWidth:(topImage.size.width / 2.0) - 1.0 topCapHeight:0.0];
		[topImage drawInRect:CGRectMake(0.0, 
										0.0, 
										boundsSize.width, 
										topImage.size.height)];
		topHeight += topImage.size.height;
	}
	
	CGFloat bottomHeight = 0.0;
	
	if (drawBottom) {
		UIImage *bottomImage = [UIImage imageNamed:bottomImageNamed];
		bottomImage = [bottomImage stretchableImageWithLeftCapWidth:(bottomImage.size.width / 2.0) - 1.0 topCapHeight:0.0];
		[bottomImage drawInRect:CGRectMake(0.0, 
										boundsSize.height - bottomImage.size.height, 
										boundsSize.width, 
										bottomImage.size.height)];
		bottomHeight += bottomImage.size.height;
	}
	
	if (boundsSize.height - topHeight - bottomHeight >= 0) {
		UIImage *middleImage = [UIImage imageNamed:middleImageNamed];
		middleImage = [middleImage stretchableImageWithLeftCapWidth:(middleImage.size.width / 2.0) - 1.0 
													   topCapHeight:0.0];
		[middleImage drawInRect:CGRectMake(0.0, 
										   topHeight, 
										   boundsSize.width, 
										   boundsSize.height - topHeight - bottomHeight)];
	}
	
#define LeftRightDiff 2.0
	
	if (drawSeparator) {
		CGContextRef context = UIGraphicsGetCurrentContext();
		
		[[UIColor colorWithHexString:@"343031"]set];
		
		CGContextSetLineWidth(context, 1.0);
		
		CGContextBeginPath(context);
		CGContextMoveToPoint(context, LeftRightDiff, (boundsSize.height - 1.0) + 0.5);
		CGContextAddLineToPoint(context, boundsSize.width - LeftRightDiff, (boundsSize.height - 1.0) + 0.5);
		CGContextStrokePath(context);
	}
	
}

- (void)dealloc {
    [super dealloc];
}


@end
