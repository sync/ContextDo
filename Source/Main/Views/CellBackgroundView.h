#import <UIKit/UIKit.h>
#import "GroupsCell.h"

@interface CellBackgroundView : UIView {

}

@property (nonatomic) CTXDOCellPosition cellPosition;
@property (nonatomic) CTXDOCellContext cellContext;

@property(nonatomic) BOOL selected;

- (void)setupCustomInitialisation;

+ (CellBackgroundView *)cellBackgroundViewWithFrame:(CGRect)frame 
									   cellPosition:(CTXDOCellPosition)aCellPosition 
										cellContext:(CTXDOCellContext)aCellContext 
										   selected:(BOOL)selected;

- (void)setCellPosition:(CTXDOCellPosition)aCellPosition context:(CTXDOCellContext)aCellContext;

@end
