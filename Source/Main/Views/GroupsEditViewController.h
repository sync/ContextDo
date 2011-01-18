#import <Foundation/Foundation.h>
#import "BaseTableViewController.h"
#import "GroupsEditDataSource.h"

@interface GroupsEditViewController : BaseTableViewController <GroupsEditDataSourceDelegate, UITextFieldDelegate> {

}

@property (nonatomic, retain) GroupsEditDataSource *groupsEditDataSource;

@property (nonatomic, readonly) NSMutableArray *groups;

- (void)refreshDataSource;

@property (nonatomic, retain) UITextField *editingTextField;
@property (nonatomic) BOOL editChangesMade;

@end
