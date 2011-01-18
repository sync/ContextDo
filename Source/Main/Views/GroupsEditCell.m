#import "GroupsEditCell.h"


@implementation GroupsEditCell

@synthesize textField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (UITextField *)textField
{
	if (!textField) {
		textField = [[[UITextField alloc]initWithFrame:CGRectZero]autorelease];
		[self.contentView addSubview:textField];
	}
	
	return textField;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
#define LeftRightDiff 10.0
	
	CGSize boundsSize = self.contentView.bounds.size;
	
	[self.textField sizeToFit];
	self.textField.frame = CGRectMake(LeftRightDiff, 
									  (boundsSize.height - self.textField.frame.size.height) / 2.0,
									  boundsSize.width - 2 * LeftRightDiff,
									  self.textField.frame.size.height);
}

@end
