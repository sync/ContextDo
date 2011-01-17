#import <UIKit/UIKit.h>

typedef enum {
	CTXDOCellPositionSingle,
	CTXDOCellPositionTop,
	CTXDOCellPositionMiddle,
	CTXDOCellPositionBottom
}CTXDOCellPosition;

typedef enum {
	CTXDOCellContextStandard,
	CTXDOCellContextExpiring,
	CTXDOCellContextLocationAware,
	CTXDOCellContextDue,
	CTXDOCellContextDueToday
}CTXDOCellContext;


@interface GroupsCell : UITableViewCell {

}

- (void)setCellPosition:(CTXDOCellPosition)cellPosition context:(CTXDOCellContext)cellContext;

@end
