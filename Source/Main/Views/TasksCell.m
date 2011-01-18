#import "TasksCell.h"
#import "AccessoryViewWithImage.h"

@implementation TasksCell

@synthesize distanceLabel, cellContext, completedButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		[self setCellContext:CTXDOCellContextStandard];
		self.textLabel.backgroundColor = [UIColor clearColor];
		self.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
		self.textLabel.textColor = [UIColor colorWithHexString:@"d8d8da"];
		self.textLabel.shadowOffset = CGSizeMake(0,-1);
		self.textLabel.shadowColor = [UIColor colorWithHexString:@"00000040"];
		self.textLabel.numberOfLines = 2.0;
		self.detailTextLabel.backgroundColor = [UIColor clearColor];
		self.detailTextLabel.font = [UIFont boldSystemFontOfSize:11.0];
		self.detailTextLabel.textColor = [UIColor colorWithHexString:@"6b6867"];
		self.detailTextLabel.shadowOffset = CGSizeMake(0,-1);
		self.detailTextLabel.shadowColor = [UIColor colorWithHexString:@"00000040"];
		self.detailTextLabel.backgroundColor = [UIColor clearColor];
		self.textLabel.numberOfLines = 2.0;
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
		distanceLabel.shadowOffset = CGSizeMake(0,-1);
		distanceLabel.shadowColor = [UIColor colorWithHexString:@"00000040"];
		[self addSubview:distanceLabel];
	}
	
	return distanceLabel;
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
	[self.completedButton setBackgroundImage:image forState:UIControlStateNormal];
	
	self.textLabel.text = task.name;
	if ([AppDelegate sharedAppDelegate].hasValidCurrentLocation && task.latitude && task.longitude) {
		self.distanceLabel.text = (task.distance / 1000.0 < 1000.0) ? [NSString stringWithFormat:@"%.1fkm", task.distance / 1000.0] : @"far away";
	} else {
		self.distanceLabel.text = nil;
	}
	
	self.detailTextLabel.text = task.location; // todo task details???
	
	[self setNeedsLayout];
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
	
#define LabelsRightDiff 5.0
	[self.textLabel sizeToFit];
	CGRect textLabelFrame = self.textLabel.frame;
	textLabelFrame.origin.x = LeftDiff;
	textLabelFrame.size.width = boundsSize.width - LeftDiff - self.distanceLabel.frame.size.width - LabelsRightDiff;
	self.textLabel.frame = CGRectIntegral(textLabelFrame);
	
#define LabelsRightDiff 5.0
	[self.detailTextLabel sizeToFit];
	CGRect detailTextLabelFrame = self.detailTextLabel.frame;
	detailTextLabelFrame.origin.x = LeftDiff;
	detailTextLabelFrame.size.width = boundsSize.width - LeftDiff - LabelsRightDiff;
	self.detailTextLabel.frame = CGRectIntegral(detailTextLabelFrame);
}

@end
