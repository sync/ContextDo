#import "GroupsCell.h"
#import "CellBackgroundView.h"

@interface GroupsCell (private)

- (void)adjustBackgroundForPosition:(CTXDOCellPosition)aCellPosition;

@end


@implementation GroupsCell

@synthesize cellPosition;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		[self adjustBackgroundForPosition:CTXDOCellPositionSingle];
		self.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
		self.textLabel.textColor = [UIColor colorWithHexString:@"929092"];
		self.textLabel.shadowOffset = CGSizeMake(0,-1);
		self.textLabel.shadowColor = [UIColor colorWithHexString:@"00000040"];
		self.textLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setCellPosition:(CTXDOCellPosition)aCellPosition
{
	if (cellPosition != aCellPosition) {
		cellPosition = aCellPosition;
		[self adjustBackgroundForPosition:aCellPosition];
	}
}

- (void)adjustBackgroundForPosition:(CTXDOCellPosition)aCellPosition
{
	CellBackgroundView *backgroundView = [[[CellBackgroundView alloc]initWithFrame:self.bounds]autorelease];
	backgroundView.cellPosition = aCellPosition;
	self.backgroundView = backgroundView;
}

@end
