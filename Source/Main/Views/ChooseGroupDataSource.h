#import <UIKit/UIKit.h>
#import "BaseTableViewDataSource.h"

@interface ChooseGroupDataSource : BaseTableViewDataSource {

}

- (Group *)groupForIndexPath:(NSIndexPath *)indexPath;

@end
