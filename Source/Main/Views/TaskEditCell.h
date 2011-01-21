#import <UIKit/UIKit.h>


@interface TaskEditCell : UITableViewCell {

}

@property (nonatomic, readonly) UITextField *textField;
@property (nonatomic, readonly) UITextView *textView;

@property (nonatomic, readonly) CTXDOCellPosition cellPosition;
@property (nonatomic, readonly) CTXDOCellContext cellContext;

@property (nonatomic, readonly) UIButton *noteButton;

- (void)setCellPosition:(CTXDOCellPosition)cellPosition context:(CTXDOCellContext)cellContext;

@end
