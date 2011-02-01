#import "TaskDetailsView.h"
#import "NSDate+Extensions.h"

@implementation TaskDetailsView


@synthesize distanceLabel, cellContext, completedButton, addressLabel, nameLabel, detailLabel, locationImageView;
@synthesize separatorLine, facebookIconView;

#define NameLabelFontSize 16.0
#define AddressLabelFontSize 11.0
#define DetailLabelFontSize 11.0

// The designated initializer. Override to perform setup that is required before the view is loaded.
// Only when xibless (interface buildder)
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Custom initialization
		[self setupCustomInitialisation];
    }
    return self;
}

// The designated initializer. Override to perform setup that is required before the view is loaded.
// Only when using xib (interface buildder)
- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		// Custom initialization
		[self setupCustomInitialisation];
	}
	return self;
}

#pragma mark -
#pragma mark Setup

- (void)setupCustomInitialisation
{	
	self.backgroundColor = [UIColor clearColor];
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

- (OHAttributedLabel *)nameLabel
{
	if (!nameLabel) {
		nameLabel = [[[OHAttributedLabel alloc]initWithFrame:CGRectZero]autorelease];
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.font = [UIFont boldSystemFontOfSize:NameLabelFontSize];
		nameLabel.textColor = [UIColor colorWithHexString:@"FFF"];
		nameLabel.highlightedTextColor = [UIColor whiteColor];
		nameLabel.shadowColor = [UIColor colorWithHexString:@"00000040"];
		nameLabel.shadowOffset = CGSizeMake(0,-1);
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.numberOfLines = 0;
		nameLabel.lineBreakMode = UILineBreakModeWordWrap;
		
		[self addSubview:nameLabel];
	}
	
	return nameLabel;
}

- (UILabel *)detailLabel
{
	if (!detailLabel) {
		detailLabel = [[[UILabel alloc]initWithFrame:CGRectZero]autorelease];
		detailLabel.backgroundColor = [UIColor clearColor];
		detailLabel.font = [UIFont boldSystemFontOfSize:DetailLabelFontSize];
		detailLabel.textColor = [UIColor colorWithHexString:@"181316"];
		detailLabel.highlightedTextColor = [UIColor whiteColor];
		detailLabel.shadowOffset = CGSizeMake(0,-1);
		detailLabel.shadowColor = [UIColor clearColor];
		detailLabel.backgroundColor = [UIColor clearColor];
		detailLabel.numberOfLines = 0;
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
		addressLabel.shadowColor = [UIColor clearColor];
		self.addressLabel.textColor = [UIColor colorWithHexString:@"181316"];
		addressLabel.backgroundColor = [UIColor clearColor];
		addressLabel.numberOfLines = 0;
		[self addSubview:addressLabel];
	}
	
	return addressLabel;
}

- (void)setCellContext:(CTXDOCellContext)aCellContext
{
	cellContext = aCellContext;
	
	if (cellContext == CTXDOCellContextStandardAlternate) {
		self.distanceLabel.font = [UIFont systemFontOfSize:11.0];
		self.distanceLabel.textColor = [UIColor colorWithHexString:@"1813167"];
		self.distanceLabel.shadowColor = [UIColor clearColor];
	} else if (cellContext == CTXDOCellContextLocationAware) {
		self.distanceLabel.font = [UIFont systemFontOfSize:12.0];
		self.distanceLabel.textColor = [UIColor colorWithHexString:@"FFF"];
		self.distanceLabel.shadowColor = [UIColor colorWithHexString:@"00000040"];
	} else {
		self.distanceLabel.font = [UIFont systemFontOfSize:11.0];
		self.distanceLabel.textColor = [UIColor colorWithHexString:@"181316"];
		self.distanceLabel.shadowColor = [UIColor clearColor];
	}
}

- (UIImageView *)separatorLine
{
	if (!separatorLine) {
		separatorLine = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"taskDetails_divider.png"]]autorelease];
		[self addSubview:separatorLine];
	}
	
	return separatorLine;
}

- (UIImageView *)facebookIconView

{
	if (!facebookIconView) {
		facebookIconView = [[[UIImageView alloc]initWithFrame:CGRectZero]autorelease];
		[self addSubview:facebookIconView];
	}
	
	return facebookIconView;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGSize boundsSize = self.bounds.size;
	
#define TopDiff 11.0
#define ImageTopDiff 5.0
#define ImageLeftDiff 10.0
	CGSize imageSize = [self.completedButton backgroundImageForState:UIControlStateNormal].size;
	self.completedButton.frame = CGRectIntegral(CGRectMake(ImageLeftDiff, 
														   TopDiff + ImageTopDiff, 
														   imageSize.width, 
														   imageSize.height));
#define LocationImageLeftDiff 56.0
#define LocationImageTopDiff 4.0
	if (self.cellContext == CTXDOCellContextLocationAware) {
		CGSize locImageSize = self.locationImageView.image.size;
		self.locationImageView.frame = CGRectIntegral(CGRectMake(LocationImageLeftDiff, LocationImageTopDiff, locImageSize.width, locImageSize.height));
	}
	

#define LeftDiff 80
#define LabelsRightDiff 15.0
#define LabelsDiff 2.0
	
#define LabelsWidth (boundsSize.width - LeftDiff - LabelsRightDiff)
	
	CGFloat totalHeight = 0.0;
	
	if (self.cellContext != CTXDOCellContextLocationAware) {		
		CGSize nameSize = [self.nameLabel sizeThatFits:CGSizeMake(LabelsWidth, CGFLOAT_MAX)];
		nameSize.width = LabelsWidth;
		[self.nameLabel sizeToFit];
		CGRect nameLabelFrame = self.nameLabel.frame;
		nameLabelFrame.origin.x = LeftDiff;
		nameLabelFrame.origin.y =TopDiff;
		nameLabelFrame.size = nameSize;
		self.nameLabel.frame = CGRectIntegral(nameLabelFrame);
		totalHeight = self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height;
		
		if (self.detailLabel.text.length > 0) {
			CGSize detailSize = [self.detailLabel sizeThatFits:CGSizeMake(LabelsWidth, CGFLOAT_MAX)];
			detailSize.width = LabelsWidth;
			[self.detailLabel sizeToFit];
			CGRect detailLabelFrame = self.detailLabel.frame;
			detailLabelFrame.origin.x = LeftDiff;
			detailLabelFrame.origin.y = totalHeight + LabelsDiff;
			detailLabelFrame.size = detailSize;
			self.detailLabel.frame = CGRectIntegral(detailLabelFrame);
			totalHeight = self.detailLabel.frame.origin.y + self.detailLabel.frame.size.height;
		} else {
			self.detailLabel.frame = CGRectZero;
		}
		
		if (self.addressLabel.text.length > 0) {
			CGSize addressSize = [self.addressLabel.text sizeWithFont:[UIFont systemFontOfSize:AddressLabelFontSize] 
													constrainedToSize:CGSizeMake(LabelsWidth, CGFLOAT_MAX)
														lineBreakMode:UILineBreakModeTailTruncation];
			addressSize.width = LabelsWidth;
			[self.addressLabel sizeToFit];
			CGRect addressLabelFrame = self.addressLabel.frame;
			addressLabelFrame.origin.x = LeftDiff;
			addressLabelFrame.origin.y =  totalHeight + LabelsDiff;
			addressLabelFrame.size = addressSize;
			addressLabelFrame.size.height = addressLabelFrame.size.height; 
			self.addressLabel.frame = CGRectIntegral(addressLabelFrame);
			totalHeight = self.addressLabel.frame.origin.y + self.addressLabel.frame.size.height;
		} else {
			self.addressLabel.frame = CGRectZero;
		}
		
#define DistanceTopDiff 10.0
		[self.distanceLabel sizeToFit];
		CGRect distanceLabelFrame = self.distanceLabel.frame;
		distanceLabelFrame.origin.x = LeftDiff;
		distanceLabelFrame.origin.y = totalHeight + LabelsDiff;
		self.distanceLabel.frame = CGRectIntegral(distanceLabelFrame);
		totalHeight = self.distanceLabel.frame.origin.y + self.distanceLabel.frame.size.height;
	} else {
#define DistanceTopDiff 10.0
		[self.distanceLabel sizeToFit];
		CGRect distanceLabelFrame = self.distanceLabel.frame;
		distanceLabelFrame.origin.x = LeftDiff;
		distanceLabelFrame.origin.y = TopDiff;
		self.distanceLabel.frame = CGRectIntegral(distanceLabelFrame);
		totalHeight = self.distanceLabel.frame.origin.y + self.distanceLabel.frame.size.height;
		
		CGSize nameSize = [self.nameLabel sizeThatFits:CGSizeMake(LabelsWidth, CGFLOAT_MAX)];
		nameSize.width = LabelsWidth;
		[self.nameLabel sizeToFit];
		CGRect nameLabelFrame = self.nameLabel.frame;
		nameLabelFrame.origin.x = LeftDiff;
		nameLabelFrame.origin.y = totalHeight + LabelsDiff;
		nameLabelFrame.size = nameSize;
		self.nameLabel.frame = CGRectIntegral(nameLabelFrame);
		totalHeight = self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height;
		
		if (self.detailLabel.text.length > 0) {
			CGSize detailSize = [self.detailLabel sizeThatFits:CGSizeMake(LabelsWidth, CGFLOAT_MAX)];
			detailSize.width = LabelsWidth;
			[self.detailLabel sizeToFit];
			CGRect detailLabelFrame = self.detailLabel.frame;
			detailLabelFrame.origin.x = LeftDiff;
			detailLabelFrame.origin.y = totalHeight + LabelsDiff;
			detailLabelFrame.size = detailSize;
			self.detailLabel.frame = CGRectIntegral(detailLabelFrame);
			totalHeight = self.detailLabel.frame.origin.y + self.detailLabel.frame.size.height;
		} else {
			self.detailLabel.frame = CGRectZero;
		}
		
		if (self.addressLabel.text.length > 0) {
			CGSize addressSize = [self.addressLabel.text sizeWithFont:[UIFont systemFontOfSize:AddressLabelFontSize] 
													constrainedToSize:CGSizeMake(LabelsWidth, CGFLOAT_MAX)
														lineBreakMode:UILineBreakModeTailTruncation];
			addressSize.width = LabelsWidth;
			[self.addressLabel sizeToFit];
			CGRect addressLabelFrame = self.addressLabel.frame;
			addressLabelFrame.origin.x = LeftDiff;
			addressLabelFrame.origin.y = totalHeight +  LabelsDiff;
			addressLabelFrame.size = addressSize;
			self.addressLabel.frame = CGRectIntegral(addressLabelFrame);
			totalHeight = self.addressLabel.frame.origin.y + self.addressLabel.frame.size.height;
		} else {
			self.addressLabel.frame = CGRectZero;
		}
	}
	
#define SeparatorToDiff 13.0
	CGSize separatorSize = self.separatorLine.image.size;
	self.separatorLine.frame = CGRectIntegral(CGRectMake(LeftDiff,
														 totalHeight + SeparatorToDiff, 
														 LabelsWidth,
														 separatorSize.height));
	totalHeight = self.separatorLine.frame.origin.y + self.separatorLine.frame.size.height;
	
	if (self.facebookIconView.image) {
		#define FacebookIconTopDiff 9.0
		CGSize facbookSize = self.facebookIconView.image.size;
		self.facebookIconView.frame = CGRectIntegral(CGRectMake(LeftDiff,
																totalHeight + FacebookIconTopDiff, 
																facbookSize.width,
																facbookSize.height));
	}
}

- (void)setTask:(Task *)task
{
	if (task.isClose) {
		self.cellContext = CTXDOCellContextLocationAware;
	} else if (task.isFacebook) {
		self.cellContext = CTXDOCellContextStandard;
	} else {
		self.cellContext = CTXDOCellContextStandard;
	}
	
	
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
	
	if (task.isClose) {
		self.distanceLabel.text = [NSString stringWithFormat:@"within %.1fkm", task.distance / 1000.0] ;
	} else if ([AppDelegate sharedAppDelegate].hasValidCurrentLocation && task.latitude && task.longitude) {
		self.distanceLabel.text = (task.distance / 1000.0 < 1000.0) ? [NSString stringWithFormat:@"%.1fkm", task.distance / 1000.0] : @"far away";
	} else {
		self.distanceLabel.text = nil;
	}
	
	NSString *relativeTime = [NSDate stringForDisplayFromDate:task.dueAt];
	
	self.nameLabel.text = (relativeTime) ? [NSString stringWithFormat:@"%@ - %@", relativeTime, task.name] : task.name;
	
	[self.nameLabel resetAttributedText];
	NSMutableAttributedString *attributedString = [NSMutableAttributedString attributedStringWithAttributedString:self.nameLabel.attributedText];
	[attributedString setFont:[UIFont systemFontOfSize:DetailLabelFontSize] range:NSMakeRange(0, relativeTime.length)];
	self.nameLabel.attributedText = attributedString;
	
	if (task.isClose) {
		self.locationImageView.image = [UIImage imageNamed:@"icon_location_white.png"];
		self.facebookIconView.image = nil;
	} else {
		self.locationImageView.image = nil;
		self.facebookIconView.image = nil;
	}
	
	self.detailLabel.text = task.info;
	self.addressLabel.text = task.location;
	
	if (task.isFacebook) {
		self.locationImageView.image = nil;
		self.facebookIconView.image = nil;
		self.facebookIconView.image = [UIImage imageNamed:@"ico_fb.png"];
	}
	
	[self setNeedsLayout];
}

@end
