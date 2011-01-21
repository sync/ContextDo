#import <UIKit/UIKit.h>
#import "DTAttributedTextContentView.h"

@interface TasksCell : UITableViewCell {

}

@property (nonatomic, readonly) UILabel *distanceLabel;
@property (nonatomic, readonly) UIImageView *locationImageView;
@property (nonatomic, readonly) UILabel *nameLabel;
@property (nonatomic, readonly) DTAttributedTextContentView *nameAttributedLabel;
@property (nonatomic, readonly) UILabel *detailLabel;
@property (nonatomic, readonly) UILabel *addressLabel;
@property (nonatomic, readonly) UIButton *completedButton;

@property (nonatomic) CTXDOCellContext cellContext;

- (void)setTask:(Task *)task;

@end
