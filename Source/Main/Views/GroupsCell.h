#import <UIKit/UIKit.h>


@interface GroupsCell : UITableViewCell {

}

@property (nonatomic, readonly) CTXDOCellPosition cellPosition;
@property (nonatomic, readonly) CTXDOCellContext cellContext;

- (void)setCellPosition:(CTXDOCellPosition)cellPosition context:(CTXDOCellContext)cellContext;

- (void)setGroup:(id)group;

@end
