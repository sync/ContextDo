#import <UIKit/UIKit.h>


@interface TaskEditCell : UITableViewCell {

}

@property (nonatomic, readonly) UITextField *textField;

@property (nonatomic, readonly) CTXDOCellPosition cellPosition;
@property (nonatomic, readonly) CTXDOCellContext cellContext;

- (void)setCellPosition:(CTXDOCellPosition)cellPosition context:(CTXDOCellContext)cellContext;

@end
