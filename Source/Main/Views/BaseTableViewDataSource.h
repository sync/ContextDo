#import <UIKit/UIKit.h>


@interface BaseTableViewDataSource : NSObject <UITableViewDataSource> {
	
}

@property (nonatomic, readonly) NSMutableArray *content;
- (void)resetContent;

- (id)objectForIndexPath:(NSIndexPath *)indexPath;

@end

@protocol BaseTableViewDataSource <NSObject>

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

