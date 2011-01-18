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
    }
    return self;
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
	if (cellContext == CTXDOCellContextStandard) {
		imageNamed = @"table_arrow_off.png";
		highlightedImageNamed = @"table_arrow_touch.png";
		textColor = [UIColor colorWithHexString:@"929092"];
		highlightedTextColor = [UIColor whiteColor];
		font = [UIFont boldSystemFontOfSize:16.0];
		leftImageNamed = @"table_vertical_line_separator_light.png";
	} else if (cellContext == CTXDOCellContextExpiring) {
		imageNamed = @"table_arrow_off.png";
		highlightedImageNamed = @"table_arrow_touch.png";
		textColor = [UIColor colorWithHexString:@"929092"];
		highlightedTextColor = [UIColor whiteColor];
		font = [UIFont boldSystemFontOfSize:16.0];
		leftImageNamed = @"table_vertical_line_separator_light.png";
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
		font = [UIFont boldSystemFontOfSize:1.0];
		leftImageNamed = @"table_vertical_line_separator.png";
	}
	self.accessoryView = [AccessoryViewWithImage accessoryViewWithImageNamed:imageNamed
													   highlightedImageNamed:highlightedImageNamed 
																  cellHeight:self.bounds.size.height 
															   leftRightDiff:10.0];
	self.textLabel.font = [UIFont boldSystemFontOfSize:16.0];;
	self.textLabel.textColor = textColor;
	self.textLabel.highlightedTextColor = highlightedTextColor;
	
	self.imageView.image = [UIImage imageNamed:leftImageNamed];
}

- (void)setGroup:(Group *)group
{
	self.textLabel.text = group.name;
	// todo
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	
}

@end
