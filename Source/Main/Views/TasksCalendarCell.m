#import "TasksCalendarCell.h"
#import "AccessoryViewWithImage.h"

@implementation TasksCalendarCell

@synthesize cellContext;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		[self setCellContext:CTXDOCellContextStandard];
		self.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
		self.textLabel.highlightedTextColor = [UIColor whiteColor];
		self.textLabel.shadowColor = [UIColor colorWithHexString:@"00000040"];
		self.textLabel.shadowOffset = CGSizeMake(0,-1);
		self.textLabel.backgroundColor = [UIColor clearColor];
		self.textLabel.textColor = [UIColor colorWithHexString:@"d8d8da"];
    }
    return self;
}

- (void)setCellContext:(CTXDOCellContext)aCellContext
{
	cellContext = aCellContext;
	
	NSString *backgroundImageNamed = nil;
	NSString *selectedBackgroundImageNamed = nil;
	NSString *imageNamed = nil;
	NSString *highlightedImageNamed = nil;
	if (cellContext == CTXDOCellContextStandardAlternate) {
		backgroundImageNamed = @"groupPanels_light.png";
		selectedBackgroundImageNamed = @"groupPanelsTouch.png";
		imageNamed = @"table_arrow_off.png";
		highlightedImageNamed = @"table_arrow_touch.png";
	} else {
		backgroundImageNamed = @"groupPanels_dark.png";
		selectedBackgroundImageNamed = @"groupPanelsTouch.png";
		imageNamed = @"table_arrow_off.png";
		highlightedImageNamed = @"table_arrow_touch.png";
	}
	
	self.backgroundView =  [[[UIImageView alloc]initWithImage:[UIImage imageNamed:backgroundImageNamed]]autorelease];;
	self.selectedBackgroundView =  [[[UIImageView alloc]initWithImage:[UIImage imageNamed:selectedBackgroundImageNamed]]autorelease];
	
	self.accessoryView = [AccessoryViewWithImage accessoryViewWithImageNamed:imageNamed
													   highlightedImageNamed:highlightedImageNamed 
																  cellHeight:self.bounds.size.height 
															   leftRightDiff:10.0];
	
	[self setNeedsLayout];
}

- (void)setTask:(Task *)task
{
	self.textLabel.text = task.name;
	
	[self setNeedsLayout];
}

@end
