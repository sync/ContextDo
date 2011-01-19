#import <Foundation/Foundation.h>
#import "BaseTableViewController.h"
#import "GroupsEditDataSource.h"

@interface GroupsEditViewController : BaseTableViewController <GroupsEditDataSourceDelegate, UITextFieldDelegate> {

}

@property (nonatomic, retain) GroupsEditDataSource *groupsEditDataSource;

- (void)refreshDataSourceForGroups:(NSArray *)groups;

@property (nonatomic, retain) UITextField *editingTextField;
@property (nonatomic) BOOL editChangesMade;

- (void)startEditingGroups:(NSArray *)groups;
- (BOOL)endEditing;

@property (nonatomic) BOOL keyboardShown;

@end
