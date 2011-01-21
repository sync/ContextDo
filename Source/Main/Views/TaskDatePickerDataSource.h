#import <UIKit/UIKit.h>
#import "BaseTableViewDataSource.h"

@interface TaskDatePickerDataSource : BaseTableViewDataSource {

}

@property (nonatomic, retain) Task *tempTask;

- (NSString *)stringForIndexPath:(NSIndexPath *)indexPath;

@end
