#import <UIKit/UIKit.h>


@interface TasksCalendarCell : UITableViewCell {

}

@property (nonatomic) CTXDOCellContext cellContext;

- (void)setTask:(Task *)task;

@end
