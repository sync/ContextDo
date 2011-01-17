#import <UIKit/UIKit.h>
#import "GroupsCell.h"

@interface CellBackgroundView : UIView {

}

@property (nonatomic) CTXDOCellPosition cellPosition;
@property (nonatomic) CTXDOCellContext cellContext;

- (void)setupCustomInitialisation;

@end
