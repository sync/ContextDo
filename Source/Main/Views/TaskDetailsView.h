#import <UIKit/UIKit.h>
#import "OHAttributedLabel.h"

@interface TaskDetailsView : UIView {

}

@property (nonatomic, readonly) UILabel *distanceLabel;
@property (nonatomic, readonly) UIImageView *locationImageView;
@property (nonatomic, readonly) OHAttributedLabel *nameLabel;
@property (nonatomic, readonly) UILabel *detailLabel;
@property (nonatomic, readonly) UILabel *addressLabel;
@property (nonatomic, readonly) UIButton *completedButton;

@property (nonatomic) CTXDOCellContext cellContext;

- (void)setTask:(Task *)task;

- (void)setupCustomInitialisation;

@end
