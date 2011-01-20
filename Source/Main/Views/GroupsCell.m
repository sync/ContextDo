#import "GroupsCell.h"
#import "CellBackgroundView.h"
#import "AccessoryViewWithImage.h"

@implementation GroupsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		[self setCellPosition:CTXDOCellPositionSingle context:CTXDOCellContextStandard];
		self.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
		self.textLabel.shadowOffset = CGSizeMake(0,-1);
		self.textLabel.shadowColor = [UIColor colorWithHexString:@"00000040"];
		self.textLabel.backgroundColor = [UIColor clearColor];
		self.detailTextLabel.font = [UIFont boldSystemFontOfSize:13.0];
		self.detailTextLabel.shadowOffset = CGSizeMake(0,-1);
		self.detailTextLabel.shadowColor = [UIColor colorWithHexString:@"d2777740"];
		self.detailTextLabel.backgroundColor = [UIColor clearColor];
		self.detailTextLabel.textColor = [UIColor colorWithHexString:@"430a0b"];
		self.detailTextLabel.highlightedTextColor = [UIColor colorWithHexString:@"430a0b"];
		self.detailTextLabel.textAlignment = UITextAlignmentCenter;
    }
    return self;
}

- (CTXDOCellPosition)cellPosition
{
	return [(CellBackgroundView *)self.backgroundView cellPosition];
}

- (CTXDOCellContext)cellContext
{
	return [(CellBackgroundView *)self.backgroundView cellContext];
}

- (void)setCellPosition:(CTXDOCellPosition)cellPosition context:(CTXDOCellContext)cellContext;
{
	CellBackgroundView *backgroundView = [CellBackgroundView cellBackgroundViewWithFrame:self.contentView.bounds 
																			cellPosition:cellPosition
																			 cellContext:cellContext
																				selected:FALSE];
	self.backgroundView = backgroundView;
	
	CellBackgroundView *selectedBackgroundView = [CellBackgroundView cellBackgroundViewWithFrame:self.contentView.bounds 
																					cellPosition:cellPosition
																					 cellContext:cellContext
																						selected:TRUE];
	self.selectedBackgroundView = selectedBackgroundView;
	
	NSString *imageNamed = nil;
	NSString *highlightedImageNamed = nil;
	UIColor *textColor = nil;
	UIColor *highlightedTextColor = nil;
	UIFont *font = nil;
	NSString *leftImageNamed = nil;
	if (cellContext == CTXDOCellContextExpiring) {
		imageNamed = @"table_arrow_off.png";
		highlightedImageNamed = @"table_arrow_touch.png";
		textColor = [UIColor colorWithHexString:@"929092"];
		highlightedTextColor = [UIColor whiteColor];
		font = [UIFont boldSystemFontOfSize:16.0];
		leftImageNamed = nil;
	} else if (cellContext == CTXDOCellContextLocationAware) {
		imageNamed = @"table_arrow_loc.png";
		highlightedImageNamed = @"table_arrow_loc_touch.png";
		textColor = [UIColor colorWithHexString:@"00a153"];
		highlightedTextColor = [UIColor colorWithHexString:@"00e375"];
		font = [UIFont boldSystemFontOfSize:16.0];
		leftImageNamed = @"icon_location.png";
	} else if (cellContext == CTXDOCellContextDue) {
		imageNamed = @"table_arrow_due_off.png";
		highlightedImageNamed = @"table_arrow_due_touch.png";
		textColor = [UIColor whiteColor];
		highlightedTextColor = [UIColor whiteColor];
		font = [UIFont boldSystemFontOfSize:16.0];
		leftImageNamed = @"table_vertical_line_separator.png";
	} else if (cellContext == CTXDOCellContextDueLight) {
		imageNamed = @"table_arrow_due_off.png";
		highlightedImageNamed = @"table_arrow_due_touch.png";
		textColor = [UIColor whiteColor];
		highlightedTextColor = [UIColor whiteColor];
		font = [UIFont boldSystemFontOfSize:10.0];
		leftImageNamed = nil;
	} else {
		imageNamed = @"table_arrow_off.png";
		highlightedImageNamed = @"table_arrow_touch.png";
		textColor = [UIColor colorWithHexString:@"929092"];
		highlightedTextColor = [UIColor whiteColor];
		font = [UIFont boldSystemFontOfSize:16.0];
		leftImageNamed = nil;
	}
	self.accessoryView = [AccessoryViewWithImage accessoryViewWithImageNamed:imageNamed
													   highlightedImageNamed:highlightedImageNamed 
																  cellHeight:self.bounds.size.height 
															   leftRightDiff:10.0];
	self.textLabel.font = font;
	self.textLabel.textColor = textColor;
	self.textLabel.highlightedTextColor = highlightedTextColor;
	
	self.imageView.image = (leftImageNamed) ? [UIImage imageNamed:leftImageNamed] : nil;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGSize boundsSize = self.contentView.bounds.size;
	
#define LeftDiff 5.0
#define ImageLeftDiff 10.0
#define ImageSeparatorLeftDiff 27.0
#define TitleLefDiff 33.0
#define RightDiff 10.0
#define CounterWidth 20.0
	
	CGRect imageViewFrame = self.imageView.frame;
	if (self.detailTextLabel.text.length == 0 && self.cellContext == CTXDOCellContextDue) {
		imageViewFrame = CGRectZero;
	} else if (self.detailTextLabel.text.length == 0 || self.cellContext == CTXDOCellContextLocationAware) {
		imageViewFrame.origin.x = ImageLeftDiff;
	} else {
		imageViewFrame.origin.x = ImageSeparatorLeftDiff;
	}
	self.imageView.frame = CGRectIntegral(imageViewFrame);
	
	if (self.cellContext == CTXDOCellContextDue) {
		self.detailTextLabel.frame = CGRectIntegral(CGRectMake(LeftDiff, 
															   0.0, 
															   CounterWidth, 
															   boundsSize.height));
	} else {
		self.detailTextLabel.frame = CGRectZero;
	}
	
	self.textLabel.frame = CGRectIntegral(CGRectMake(TitleLefDiff, 
													 0.0, 
													 boundsSize.width - TitleLefDiff - RightDiff, 
													 boundsSize.height));
}

- (void)setGroup:(Group *)group
{
	self.textLabel.text = group.name;
	
	self.detailTextLabel.text = (group.expiredCount.integerValue > 0) ?  [group.expiredCount stringValue] : nil;
	[self setNeedsLayout];
}

@end
