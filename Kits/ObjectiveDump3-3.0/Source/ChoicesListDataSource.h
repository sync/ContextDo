#import <Foundation/Foundation.h>
#import "BaseTableViewDataSource.h"

@interface ChoicesListDataSource : BaseTableViewDataSource <BaseTableViewDataSource> {

}

- (id)initWitChoicesList:(NSArray *)choicesList;

- (NSString *)choiceForIndexPath:(NSIndexPath *)indexPath;

@end
