#import <UIKit/UIKit.h>
#import "BaseTableViewDataSource.h"

#define TitlePlaceholder @"Title"
#define InfoPlaceholder @"Info"
#define LocationPlaceholder @"Place, Street, Suburb"
#define AddContactPlaceholder @"Contact Name - Detail"
#define TimePlaceholder @"Time"
#define AlertsPlaceholder @"Alerts Inform / update"
#define GroupPlaceholder @"Group"

@interface TaskEditDataSource : BaseTableViewDataSource {

}

- (NSString *)valueForIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)tagForIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForTag:(NSInteger)tag;

- (void)setValue:(NSString *)value forIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, retain) Task *tempTask;

- (BOOL)isIndexPathInput:(NSIndexPath *)indexPath;
- (BOOL)isIndexPathInputMulti:(NSIndexPath *)indexPath;
- (BOOL)hasNoteEdit:(NSIndexPath *)indexPath;
- (BOOL)hasDetailDisclosure:(NSIndexPath *)indexPath;

@end
