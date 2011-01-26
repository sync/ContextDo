#import "SettingsCell.h"
#import "CellBackgroundView.h"

@implementation SettingsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		[self setCellPosition:CTXDOCellPositionSingle];
		self.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
		self.textLabel.textColor = [UIColor colorWithHexString:@"929092"];
		self.textLabel.shadowColor = [UIColor colorWithHexString:@"00000040"];
		self.textLabel.shadowOffset = CGSizeMake(0,-1);
		self.textLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (CTXDOCellPosition)cellPosition
{
	return [(CellBackgroundView *)self.backgroundView cellPosition];
}

- (void)setCellPosition:(CTXDOCellPosition)cellPosition
{
	CellBackgroundView *backgroundView = [CellBackgroundView cellBackgroundViewWithFrame:self.contentView.bounds 
																			cellPosition:cellPosition
																			 cellContext:CTXDOCellContextStandard
																				selected:FALSE];
	self.backgroundView = backgroundView;
	
	CellBackgroundView *selectedBackgroundView = [CellBackgroundView cellBackgroundViewWithFrame:self.contentView.bounds 
																					cellPosition:cellPosition
																					 cellContext:CTXDOCellContextStandard
																						selected:TRUE];
	self.selectedBackgroundView = selectedBackgroundView;
}

@end
