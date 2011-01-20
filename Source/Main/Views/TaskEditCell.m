#import "TaskEditCell.h"
#import "AccessoryViewWithImage.h"
#import "CellBackgroundView.h"

@implementation TaskEditCell

@synthesize	textField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		self.textLabel.shadowOffset = CGSizeMake(0,-1);
		self.textLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (UITextField *)textField
{
	if (!textField) {
		textField = [[[UITextField alloc]initWithFrame:CGRectZero]autorelease];
		textField.keyboardAppearance = UIKeyboardAppearanceAlert;
		textField.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:textField];
	}
	
	return textField;
}

- (CTXDOCellPosition)cellPosition
{
	return [(CellBackgroundView *)self.backgroundView cellPosition];
}

- (CTXDOCellContext)cellContext
{
	return [(CellBackgroundView *)self.backgroundView cellContext];
}

- (void)setCellPosition:(CTXDOCellPosition)cellPosition context:(CTXDOCellContext)cellContext
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
	UIColor *shadowColor = nil;
	if (cellContext == CTXDOCellContextTaskEditInput) {
		imageNamed = nil;
		highlightedImageNamed = nil;
		textColor = [UIColor colorWithHexString:@"4f4c50"];
		font = [UIFont systemFontOfSize:16.0];
		shadowColor = nil;
	} else {
		imageNamed = @"btn_std_arrow_off.png";
		highlightedImageNamed = @"btn_std_arrow_touch.png";
		textColor = [UIColor colorWithHexString:@"929092"];
		font = [UIFont boldSystemFontOfSize:16.0];
		shadowColor = [UIColor colorWithHexString:@"00000040"];
	}
	if (highlightedImageNamed && imageNamed) {
		self.accessoryView = [AccessoryViewWithImage accessoryViewWithImageNamed:imageNamed
														   highlightedImageNamed:highlightedImageNamed 
																	  cellHeight:self.bounds.size.height 
																   leftRightDiff:10.0];
	} else {
		self.accessoryView = nil;
	}
	
	self.textLabel.font = font;
	self.textLabel.textColor = textColor;
	self.textLabel.highlightedTextColor = highlightedTextColor;
	self.textLabel.shadowColor = shadowColor;
	self.textField.font = font;
	self.textField.textColor = textColor;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
#define LeftRightDiff 10.0
	
	CGSize boundsSize = self.contentView.bounds.size;
	
	if (self.cellContext == CTXDOCellContextTaskEditInput) {
		[self.textField sizeToFit];
		self.textField.frame = CGRectMake(LeftRightDiff, 
										  (boundsSize.height - self.textField.frame.size.height) / 2.0,
										  boundsSize.width - 2 * LeftRightDiff,
										  self.textField.frame.size.height);
	} else {
		self.textField.frame = CGRectZero;
	}
	
	
}

@end
