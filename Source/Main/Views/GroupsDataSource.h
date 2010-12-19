#import <Foundation/Foundation.h>
#import "BaseTableViewDataSource.h"

@interface GroupsDataSource : BaseTableViewDataSource {

}

- (Group *)groupForIndexPath:(NSIndexPath *)indexPath;

@end
