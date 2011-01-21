#import "TaskEditCell.h"
#import "CellBackgroundView.h"

@implementation TaskEditCell

@synthesize	textField, textView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		[self setCellPosition:CTXDOCellPositionSingle context:CTXDOCellContextStandard];
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

- (UITextView *)textView
{
	if (!textView) {
		textView = [[[UITextView alloc]initWithFrame:CGRectZero]autorelease];
		textView.keyboardAppearance = UIKeyboardAppearanceAlert;
		textView.backgroundColor = [UIColor clearColor];
		textView.scrollEnabled = FALSE;
		[self.contentView addSubview:textView];
	}
	
	return textView;
}

- (UIButton *)noteButton
{
	UIButton *button = (UIButton *)self.accessoryView;
	return ([button isMemberOfClass:[UIButton class]]) ? button : nil;
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
	
	UIColor *textColor = nil;
	UIColor *highlightedTextColor = nil;
	UIFont *font = nil;
	UIColor *shadowColor = nil;
	if (cellContext == CTXDOCellContextTaskEditInput) {
		textColor = [UIColor colorWithHexString:@"4f4c50"];
		font = [UIFont systemFontOfSize:16.0];
		shadowColor = nil;
	} else if (cellContext == CTXDOCellContextTaskEditInputMutliLine) {
		textColor = [UIColor colorWithHexString:@"4f4c50"];
		font = [UIFont systemFontOfSize:14.0];
		shadowColor = nil;
	} else {
		textColor = [UIColor colorWithHexString:@"929092"];
		font = [UIFont boldSystemFontOfSize:16.0];
		shadowColor = [UIColor colorWithHexString:@"00000040"];
	}
	
	self.textLabel.font = font;
	self.textLabel.textColor = textColor;
	self.textLabel.highlightedTextColor = highlightedTextColor;
	self.textLabel.shadowColor = shadowColor;
	self.textField.font = font;
	self.textField.textColor = textColor;
	self.textView.font = font;
	self.textView.textColor = textColor;
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
	} else if (self.cellContext == CTXDOCellContextTaskEditInputMutliLine) {
		self.textField.frame = CGRectZero;
		self.textView.frame = self.contentView.bounds;
	} else {
		self.textField.frame = CGRectZero;
	}
	
	
}

@end
