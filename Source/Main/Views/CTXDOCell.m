#import "CTXDOCell.h"


@implementation CTXDOCell

@synthesize distanceLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (UILabel *)distanceLabel
{
	if (!distanceLabel) {
		distanceLabel = [[[UILabel alloc]initWithFrame:CGRectZero]autorelease];
		distanceLabel.backgroundColor = [UIColor clearColor];
		distanceLabel.font = [UIFont systemFontOfSize:14.0];
		distanceLabel.textColor = [UIColor darkGrayColor];
		[self addSubview:distanceLabel];
	}
	
	return distanceLabel;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGSize boundsSize = self.contentView.bounds.size;
	
#define DistanceLeftDiff 10.0
#define DistanceTopDiff 2.0
	[self.distanceLabel sizeToFit];
	CGRect distanceLabelFrame = self.distanceLabel.frame;
	distanceLabelFrame.origin.x = boundsSize.width - distanceLabelFrame.size.width - DistanceLeftDiff;
	distanceLabelFrame.origin.y = self.textLabel.frame.origin.y + DistanceTopDiff;
	self.distanceLabel.frame = CGRectIntegral(distanceLabelFrame);
	
#define LabelsDiff 5.0
	[self.distanceLabel sizeToFit];
	CGRect textLabelFrame = self.textLabel.frame;
	textLabelFrame.size.width = boundsSize.width - (textLabelFrame.origin.x * 2.0) - LabelsDiff - self.distanceLabel.frame.size.width;
	self.textLabel.frame = CGRectIntegral(textLabelFrame);
}

@end
