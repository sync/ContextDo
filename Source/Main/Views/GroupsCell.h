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
	CTXDOCellContextDueLight
}CTXDOCellContext;


@interface GroupsCell : UITableViewCell {

}

@property (nonatomic, readonly) CTXDOCellPosition cellPosition;
@property (nonatomic, readonly) CTXDOCellContext cellContext;

- (void)setCellPosition:(CTXDOCellPosition)cellPosition context:(CTXDOCellContext)cellContext;

- (void)setGroup:(Group *)group;

@end
