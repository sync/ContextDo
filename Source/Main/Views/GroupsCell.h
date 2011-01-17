#import <UIKit/UIKit.h>

typedef enum {
	CTXDOCellPositionSingle,
	CTXDOCellPositionTop,
	CTXDOCellPositionMiddle,
	CTXDOCellPositionBottom
}CTXDOCellPosition;

@interface GroupsCell : UITableViewCell {

}

@property (nonatomic) CTXDOCellPosition cellPosition;

@end
