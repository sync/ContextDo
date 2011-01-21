#import "TasksCell.h"
#import "AccessoryViewWithImage.h"
#import "NSDate+Helper.h"

@implementation TasksCell

@synthesize distanceLabel, cellContext, completedButton, addressLabel, nameLabel, detailLabel, locationImageView, nameAttributedLabel;

#define NameLabelFontSize 16.0
#define AddressLabelFontSize 11.0
#define DetailLabelFontSize 11.0

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		[self setCellContext:CTXDOCellContextStandard];
    }
    return self;
}

- (UILabel *)textLabel
{
	return nil;
}

- (UILabel *)detailTextLabel
{
	return nil;
}

- (UIButton *)completedButton
{
	if (!completedButton) {
		completedButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[self addSubview:completedButton];
	}
	
	return completedButton;
}

- (UIImageView *)locationImageView
{
	if (!locationImageView) {
		locationImageView = [[[UIImageView alloc]initWithFrame:CGRectZero]autorelease];
		[self addSubview:locationImageView];
	}
	
	return locationImageView;
}

- (UILabel *)distanceLabel
{
	if (!distanceLabel) {
		distanceLabel = [[[UILabel alloc]initWithFrame:CGRectZero]autorelease];
		distanceLabel.backgroundColor = [UIColor clearColor];
		distanceLabel.highlightedTextColor = [UIColor whiteColor];
		distanceLabel.shadowOffset = CGSizeMake(0,-1);
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
		nameLabel.highlightedTextColor = [UIColor whiteColor];
		nameLabel.shadowColor = [UIColor colorWithHexString:@"00000040"];
		nameLabel.shadowOffset = CGSizeMake(0,-1);
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.numberOfLines = 0;
		[self addSubview:nameLabel];
	}
	
	return nameLabel;
}

- (DTAttributedTextContentView *)nameAttributedLabel
{
	if (!nameAttributedLabel) {
		nameAttributedLabel = [[[DTAttributedTextContentView alloc] initWithFrame:CGRectZero] autorelease];
		nameAttributedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		nameAttributedLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:nameAttributedLabel];
	}
	
	return nameAttributedLabel;
}

- (UILabel *)detailLabel
{
	if (!detailLabel) {
		detailLabel = [[[UILabel alloc]initWithFrame:CGRectZero]autorelease];
		detailLabel.backgroundColor = [UIColor clearColor];
		detailLabel.font = [UIFont boldSystemFontOfSize:DetailLabelFontSize];
		detailLabel.textColor = [UIColor colorWithHexString:@"6b6867"];
		detailLabel.highlightedTextColor = [UIColor whiteColor];
		detailLabel.shadowOffset = CGSizeMake(0,-1);
		detailLabel.shadowColor = [UIColor colorWithHexString:@"00000040"];
		detailLabel.backgroundColor = [UIColor clearColor];
		detailLabel.numberOfLines = 1;
		[self addSubview:detailLabel];
	}
	
	return detailLabel;
}

- (UILabel *)addressLabel
{
	if (!addressLabel) {
		addressLabel = [[[UILabel alloc]initWithFrame:CGRectZero]autorelease];
		addressLabel.backgroundColor = [UIColor clearColor];
		addressLabel.font = [UIFont systemFontOfSize:AddressLabelFontSize];
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
		self.distanceLabel.font = [UIFont boldSystemFontOfSize:11.0];
		self.distanceLabel.textColor = [UIColor colorWithHexString:@"6b6867"];
		self.distanceLabel.shadowColor = [UIColor colorWithHexString:@"00000040"];
		self.nameLabel.textColor = [UIColor colorWithHexString:@"d8d8da"];
		self.addressLabel.textColor = [UIColor colorWithHexString:@"6b6867"];
	} else if (cellContext == CTXDOCellContextLocationAware) {
		backgroundImageNamed = @"groupPanels_green.png";
		selectedBackgroundImageNamed = @"groupPanels_green.png";
		imageNamed = @"table_arrow_loc.png";
		highlightedImageNamed = @"table_arrow_loc_touch.png";
		self.distanceLabel.font = [UIFont boldSystemFontOfSize:12.0];
		self.distanceLabel.textColor = [UIColor colorWithHexString:@"004624"];
		self.distanceLabel.shadowColor = [UIColor clearColor];
		self.nameLabel.textColor = [UIColor colorWithHexString:@"f7f3ea"];
		self.addressLabel.textColor = [UIColor colorWithHexString:@"FFF"];
	} else {
		backgroundImageNamed = @"groupPanels_dark.png";
		selectedBackgroundImageNamed = @"groupPanels_dark.png";
		imageNamed = @"table_arrow_off.png";
		highlightedImageNamed = @"table_arrow_touch.png";
		self.distanceLabel.font = [UIFont boldSystemFontOfSize:11.0];
		self.distanceLabel.textColor = [UIColor colorWithHexString:@"6b6867"];
		self.distanceLabel.shadowColor = [UIColor colorWithHexString:@"00000040"];
		self.nameLabel.textColor = [UIColor colorWithHexString:@"d8d8da"];
		self.addressLabel.textColor = [UIColor colorWithHexString:@"6b6867"];
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
#define LocationImageLeftDiff 56.0
#define LocationImageTopDiff 4.0
	if (self.cellContext == CTXDOCellContextLocationAware) {
		CGSize locImageSize = self.locationImageView.image.size;
		self.locationImageView.frame = CGRectIntegral(CGRectMake(LocationImageLeftDiff, LocationImageTopDiff, locImageSize.width, locImageSize.height));
	}

#define TopDiff 11.0
#define LeftDiff 80
#define LabelsRightDiff 10.0
#define LabelsDiff 2.0
	
#define LabelsWidth (boundsSize.width - LeftDiff - LabelsRightDiff)
	
	if (self.cellContext != CTXDOCellContextLocationAware) {
#define DistanceRightDiff -20.0
#define DistanceTopDiff 10.0
		[self.distanceLabel sizeToFit];
		CGRect distanceLabelFrame = self.distanceLabel.frame;
		distanceLabelFrame.origin.x = boundsSize.width - distanceLabelFrame.size.width - DistanceRightDiff;
		distanceLabelFrame.origin.y = DistanceTopDiff;
		self.distanceLabel.frame = CGRectIntegral(distanceLabelFrame);
		
		CGFloat nameLabelTwoLinesHeight = 2 * NameLabelFontSize + 8.0;
		CGSize nameSize = [self.nameLabel.text sizeWithFont:[UIFont systemFontOfSize:NameLabelFontSize] 
											   constrainedToSize:CGSizeMake(LabelsWidth, nameLabelTwoLinesHeight)
												   lineBreakMode:UILineBreakModeTailTruncation];
		nameSize.width = LabelsWidth;
		[self.nameLabel sizeToFit];
		CGRect nameLabelFrame = self.nameLabel.frame;
		nameLabelFrame.origin.x = LeftDiff;
		nameLabelFrame.origin.y =TopDiff;
		nameLabelFrame.size = nameSize;
		BOOL nameLabelIsTwoLine = (nameLabelFrame.size.height > nameLabelTwoLinesHeight / 2.0);
		
		self.nameLabel.frame = CGRectIntegral(nameLabelFrame);
		
		if (self.detailLabel.text.length > 0) {
			[self.detailLabel sizeToFit];
			CGRect detailLabelFrame = self.detailLabel.frame;
			detailLabelFrame.origin.x = LeftDiff;
			detailLabelFrame.origin.y = self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height + LabelsDiff;
			detailLabelFrame.size.width = LabelsWidth;
			detailLabelFrame.size.height = DetailLabelFontSize + 4.0;  // 1 line
			self.detailLabel.frame = CGRectIntegral(detailLabelFrame);
		} else {
			self.detailLabel.frame = CGRectZero;
		}
		
		if (self.addressLabel.text.length > 0) {
			CGFloat addressLabelTwoLinesHeight = 2 * AddressLabelFontSize + 8.0;
			CGSize addressSize = [self.addressLabel.text sizeWithFont:[UIFont systemFontOfSize:AddressLabelFontSize] 
												   constrainedToSize:CGSizeMake(LabelsWidth, addressLabelTwoLinesHeight)
													   lineBreakMode:UILineBreakModeTailTruncation];
			addressSize.width = LabelsWidth;
			[self.addressLabel sizeToFit];
			CGRect addressLabelFrame = self.addressLabel.frame;
			addressLabelFrame.origin.x = LeftDiff;
			addressLabelFrame.origin.y = self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height + LabelsDiff + self.detailLabel.frame.size.height + LabelsDiff;
			addressLabelFrame.size = addressSize;
			addressLabelFrame.size.height = (nameLabelIsTwoLine || self.detailLabel.text.length > 0) ? AddressLabelFontSize + 4.0 : addressLabelFrame.size.height; 
			self.addressLabel.frame = CGRectIntegral(addressLabelFrame);
		} else {
			self.addressLabel.frame = CGRectZero;
		}
	} else {
#define DistanceTopDiff 10.0
		[self.distanceLabel sizeToFit];
		CGRect distanceLabelFrame = self.distanceLabel.frame;
		distanceLabelFrame.origin.x = LeftDiff;
		distanceLabelFrame.origin.y = TopDiff;
		self.distanceLabel.frame = CGRectIntegral(distanceLabelFrame);
		
		[self.nameLabel sizeToFit];
		CGRect nameLabelFrame = self.nameLabel.frame;
		nameLabelFrame.origin.x = LeftDiff;
		nameLabelFrame.origin.y = self.distanceLabel.frame.origin.y + self.distanceLabel.frame.size.height + LabelsDiff;
		nameLabelFrame.size.width = LabelsWidth;
		nameLabelFrame.size.height = NameLabelFontSize + 4.0;
		self.nameLabel.frame = CGRectIntegral(nameLabelFrame);
		
		self.detailLabel.frame = CGRectZero;
		
		if (self.addressLabel.text.length > 0) {
			CGFloat addressLabelTwoLinesHeight = 2 * AddressLabelFontSize + 8.0;
			CGSize addressSize = [self.addressLabel.text sizeWithFont:[UIFont systemFontOfSize:AddressLabelFontSize] 
												   constrainedToSize:CGSizeMake(LabelsWidth, addressLabelTwoLinesHeight)
													   lineBreakMode:UILineBreakModeTailTruncation];
			addressSize.width = LabelsWidth;
			[self.addressLabel sizeToFit];
			CGRect addressLabelFrame = self.addressLabel.frame;
			addressLabelFrame.origin.x = LeftDiff;
			addressLabelFrame.origin.y = self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height + LabelsDiff + self.detailLabel.frame.size.height + LabelsDiff;
			addressLabelFrame.size = addressSize;
			self.addressLabel.frame = CGRectIntegral(addressLabelFrame);
		} else {
			self.addressLabel.frame = CGRectZero;
		}
	}
}

- (void)setTask:(Task *)task
{
	NSString *imageNamed = nil;
	if (task.expired) {
		imageNamed = @"btn_todo_due.png";
	} else if (task.completed) {
		imageNamed = @"btn_todo_done.png";
	} else if (task.isClose) {
		imageNamed = @"btn_todo_loc.png";
	} else {
		imageNamed = @"btn_todo_std.png";
	}
	UIImage *image = [UIImage imageNamed:imageNamed];
	[self.completedButton setBackgroundImage:image forState:UIControlStateNormal];
	[self.completedButton setBackgroundImage:image forState:UIControlStateHighlighted];
	
	if ([AppDelegate sharedAppDelegate].hasValidCurrentLocation && task.latitude && task.longitude) {
		self.distanceLabel.text = (task.distance / 1000.0 < 1000.0) ? [NSString stringWithFormat:@"%.1fkm", task.distance / 1000.0] : @"far away";
	} else {
		self.distanceLabel.text = nil;
	}
	
	NSString *relativeTime = [NSDate stringForDisplayFromDate:task.dueAt];
	self.nameLabel.text = (relativeTime) ? [NSString stringWithFormat:@"%@ - %@", relativeTime, task.name] : task.name;
	
	if (task.isClose) {
		self.locationImageView.image = [UIImage imageNamed:@"icon_location_white.png"];
		self.detailLabel.text = nil;
	} else {
		self.locationImageView.image = nil;
		self.detailLabel.text = @"carrots, veggies, soap";
	}
	
	self.addressLabel.text = task.location;
	
	[self setNeedsLayout];
}

@end
