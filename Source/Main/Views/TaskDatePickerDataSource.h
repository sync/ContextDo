#import <UIKit/UIKit.h>
#import "BaseTableViewDataSource.h"

@interface TaskDatePickerDataSource : BaseTableViewDataSource {

}

@property (nonatomic, retain) Task *task;

- (NSString *)stringForIndexPath:(NSIndexPath *)indexPath;

@end
