#import <UIKit/UIKit.h>

@interface TasksCell : UITableViewCell {

}

@property (nonatomic, readonly) UILabel *distanceLabel;
@property (nonatomic, readonly) UILabel *nameLabel;
@property (nonatomic, readonly) UILabel *detailLabel;
@property (nonatomic, readonly) UILabel *addressLabel;
@property (nonatomic, readonly) UIButton *completedButton;

@property (nonatomic) CTXDOCellContext cellContext;

- (void)setTask:(Task *)task;

@end
