#import "TasksCell.h"
#import "AccessoryViewWithImage.h"

@implementation TasksCell

@synthesize distanceLabel, cellContext, completedButton, addressLabel, nameLabel;

#define NameLabelFontSize 16.0
#define AddressLabelFontSize 11.0

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		[self setCellContext:CTXDOCellContextStandard];
    }
    return self;
}

- (UIButton *)completedButton
{
	if (!completedButton) {
		completedButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[self addSubview:completedButton];
	}
	
	return completedButton;
}

- (UILabel *)distanceLabel
{
	if (!distanceLabel) {
		distanceLabel = [[[UILabel alloc]initWithFrame:CGRectZero]autorelease];
		distanceLabel.backgroundColor = [UIColor clearColor];
		distanceLabel.font = [UIFont boldSystemFontOfSize:11.0];
		distanceLabel.textColor = [UIColor colorWithHexString:@"6b6867"];
		distanceLabel.highlightedTextColor = [UIColor whiteColor];
		distanceLabel.shadowOffset = CGSizeMake(0,-1);
		distanceLabel.shadowColor = [UIColor colorWithHexString:@"00000040"];
		[self addSubview:distanceLabel];
	}
	
	return distanceLabel;
}

- (UILabel *)nameLabel
{
	if (!nameLabel) {
		nameLabel = [[[UILabel alloc]initWithFrame:CGRectZero]autorelease];
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.font = [UIFont boldSystemFontOfSize:NameLabelFontSize];
		nameLabel.textColor = [UIColor colorWithHexString:@"d8d8da"];
		nameLabel.highlightedTextColor = [UIColor whiteColor];
		nameLabel.shadowOffset = CGSizeMake(0,-1);
		nameLabel.shadowColor = [UIColor colorWithHexString:@"00000040"];
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.numberOfLines = 0;
		[self addSubview:nameLabel];
	}
	
	return nameLabel;
}

- (UILabel *)addressLabel
{
	if (!addressLabel) {
		addressLabel = [[[UILabel alloc]initWithFrame:CGRectZero]autorelease];
		addressLabel.backgroundColor = [UIColor clearColor];
		addressLabel.font = [UIFont boldSystemFontOfSize:AddressLabelFontSize];
		addressLabel.textColor = [UIColor colorWithHexString:@"6b6867"];
		addressLabel.highlightedTextColor = [UIColor whiteColor];
		addressLabel.shadowOffset = CGSizeMake(0,-1);
		addressLabel.shadowColor = [UIColor colorWithHexString:@"00000040"];
		addressLabel.backgroundColor = [UIColor clearColor];
		addressLabel.numberOfLines = 0;
		[self addSubview:addressLabel];
	}
	
	return addressLabel;
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
		selectedBackgroundImageNamed = @"groupPanels_light.png";
		imageNamed = @"table_arrow_off.png";
		highlightedImageNamed = @"table_arrow_touch.png";
	} else if (cellContext == CTXDOCellContextLocationAware) {
		backgroundImageNamed = @"groupPanels_greeen.png";
		selectedBackgroundImageNamed = @"groupPanels_greeen.png";
		imageNamed = @"table_arrow_loc.png";
		highlightedImageNamed = @"table_arrow_loc_touch.png";
	} else {
		backgroundImageNamed = @"groupPanels_dark.png";
		selectedBackgroundImageNamed = @"groupPanels_dark.png";
		imageNamed = @"table_arrow_off.png";
		highlightedImageNamed = @"table_arrow_touch.png";
	}
	
	self.backgroundView =  [[[UIImageView alloc]initWithImage:[UIImage imageNamed:backgroundImageNamed]]autorelease];;
	
										  // TODO ask
//	self.selectedBackgroundView =  [[[UIImageView alloc]initWithImage:[UIImage imageNamed:selectedBackgroundImageNamed]]autorelease];
	
	self.accessoryView = [AccessoryViewWithImage accessoryViewWithImageNamed:imageNamed
													   highlightedImageNamed:highlightedImageNamed 
																  cellHeight:self.bounds.size.height 
															   leftRightDiff:10.0];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGSize boundsSize = self.contentView.bounds.size;

#define ImageLeftDiff 10.0
	CGSize imageSize = [self.completedButton backgroundImageForState:UIControlStateNormal].size;
	self.completedButton.frame = CGRectIntegral(CGRectMake(ImageLeftDiff, 
														   (boundsSize.height - imageSize.height) / 2.0, 
														   imageSize.width, 
														   imageSize.height));
#define LeftDiff 80
	
#define DistanceRightDiff -20.0
#define DistanceTopDiff 10.0
	[self.distanceLabel sizeToFit];
	CGRect distanceLabelFrame = self.distanceLabel.frame;
	distanceLabelFrame.origin.x = boundsSize.width - distanceLabelFrame.size.width - DistanceRightDiff;
	distanceLabelFrame.origin.y = DistanceTopDiff;
	self.distanceLabel.frame = CGRectIntegral(distanceLabelFrame);
	
#define TopDiff 11.0
#define LabelsRightDiff 10.0
	[self.nameLabel sizeToFit];
	CGRect nameLabelFrame = self.nameLabel.frame;
	nameLabelFrame.origin.x = LeftDiff;
	nameLabelFrame.origin.y = TopDiff;
	nameLabelFrame.size.width = boundsSize.width - LeftDiff - LabelsRightDiff;
	CGFloat nameLabelTwoLinesHeight = 2 * NameLabelFontSize + 8.0;
	BOOL nameLabelIsTwoLine = (nameLabelFrame.size.height > nameLabelTwoLinesHeight);
	nameLabelFrame.size.height = (nameLabelIsTwoLine) ? nameLabelTwoLinesHeight : nameLabelFrame.size.height;  // 2 lines
	self.nameLabel.frame = CGRectIntegral(nameLabelFrame);
	
#define LabelsDiff 2.0
	[self.addressLabel sizeToFit];
	CGRect addressLabelFrame = self.addressLabel.frame;
	addressLabelFrame.origin.x = LeftDiff;
	addressLabelFrame.origin.y = self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height + LabelsDiff;
	addressLabelFrame.size.width = boundsSize.width - LeftDiff - LabelsRightDiff;
	CGFloat addressLabelTwoLinesHeight = 2 * AddressLabelFontSize + 8.0;
	BOOL addressLabelIsTwoLine = (addressLabelFrame.size.height > nameLabelTwoLinesHeight);
	addressLabelFrame.size.height = (addressLabelIsTwoLine) ? addressLabelTwoLinesHeight : addressLabelFrame.size.height;  // 2 lines
	addressLabelFrame.size.height = (nameLabelIsTwoLine) ? AddressLabelFontSize + 4.0 : addressLabelFrame.size.height;  // 2 lines
	self.addressLabel.frame = CGRectIntegral(addressLabelFrame);
}

- (void)setTask:(Task *)task
{
	NSString *imageNamed = nil;
	if (task.expired) {
		imageNamed = @"btn_todo_due.png";
	} else if (task.completed) {
		imageNamed = @"btn_todo_done.png";
	} else {
		imageNamed = @"btn_todo_std.png";
	}
	// location TODO
	UIImage *image = [UIImage imageNamed:imageNamed];
	[self.completedButton setBackgroundImage:image forState:UIControlStateNormal];
	[self.completedButton setBackgroundImage:image forState:UIControlStateHighlighted];
	
	self.nameLabel.text = task.name;
	if ([AppDelegate sharedAppDelegate].hasValidCurrentLocation && task.latitude && task.longitude) {
		self.distanceLabel.text = (task.distance / 1000.0 < 1000.0) ? [NSString stringWithFormat:@"%.1fkm", task.distance / 1000.0] : @"far away";
	} else {
		self.distanceLabel.text = nil;
	}
	
	self.addressLabel.text = task.location; // todo task details???
	
	[self setNeedsLayout];
}

@end
