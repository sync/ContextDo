#import "TasksInfoCell.h"


@implementation TasksInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		[self setCellPosition:CTXDOCellPositionSingle context:CTXDOCellContextUpatedTasksLight];
    }
    return self;
}

- (void)setTask:(Task *)task;
{
	self.textLabel.text = task.name;
	[self setNeedsLayout];
}


@end
