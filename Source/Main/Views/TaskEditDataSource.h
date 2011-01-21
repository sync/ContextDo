#import <UIKit/UIKit.h>
#import "BaseTableViewDataSource.h"

#define TitlePlaceHolder @"Title"
#define LocationPlaceHolder @"Location"
#define AddContactPlaceHolder @"Contact Name - Detail"
#define TimePlaceHolder @"Time"
#define AlertsPlaceHolder @"Alerts Inform / update"
#define GroupPlaceHolder @"Group"

@interface TaskEditDataSource : BaseTableViewDataSource {

}

- (NSString *)valueForIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)tagForIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForTag:(NSInteger)tag;

- (void)setValue:(NSString *)value forIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, retain) Task *tempTask;

- (BOOL)isIndexPathInput:(NSIndexPath *)indexPath;
- (BOOL)hasDetailDisclosure:(NSIndexPath *)indexPath;

@end
