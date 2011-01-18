#import <UIKit/UIKit.h>

@interface TasksCell : UITableViewCell {

}

@property (nonatomic, readonly) UILabel *distanceLabel;
@property (nonatomic, readonly) UIButton *completedButton;

@property (nonatomic) CTXDOCellContext cellContext;

- (void)setTask:(Task *)task;

@end
