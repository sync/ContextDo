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
		self.textLabel.textColor = [UIColor colorWithHexString:@"929092"];
		self.textLabel.shadowOffset = CGSizeMake(0,-1);
		self.textLabel.shadowColor = [UIColor colorWithHexString:@"00000040"];
		self.textLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setCellPosition:(CTXDOCellPosition)cellPosition context:(CTXDOCellContext)cellContext;
{
	CellBackgroundView *backgroundView = [[[CellBackgroundView alloc]initWithFrame:self.contentView.bounds]autorelease];
	backgroundView.cellPosition = cellPosition;
	backgroundView.cellContext = cellContext;
	self.backgroundView = backgroundView;
	
	NSString *imageNamed = nil;
	NSString *highlightedImageNamed = nil;
	if (cellContext == CTXDOCellContextStandard) {
		imageNamed = @"table_arrow_off.png";
		highlightedImageNamed = @"table_arrow_touch.png";
	} else if (cellContext == CTXDOCellContextExpiring) {
		imageNamed = @"table_arrow_off.png";
		highlightedImageNamed = @"table_arrow_touch.png";
	} else if (cellContext == CTXDOCellContextLocationAware) {
		imageNamed = @"table_arrow_loc.png";
		highlightedImageNamed = @"table_arrow_loc_touch.png";
	} else if (cellContext == CTXDOCellContextDue) {
		imageNamed = @"table_arrow_due_off.png";
		highlightedImageNamed = @"table_arrow_due_touch.png";
	} else if (cellContext == CTXDOCellContextDueToday) {
		imageNamed = @"table_arrow_due_off.png";
		highlightedImageNamed = @"table_arrow_due_touch.png";
	}
	self.accessoryView = [AccessoryViewWithImage accessoryViewWithImageNamed:imageNamed
													   highlightedImageNamed:highlightedImageNamed 
																  cellHeight:self.bounds.size.height 
															   leftRightDiff:10.0];
}

@end
