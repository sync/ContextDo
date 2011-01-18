#import "GroupsDataSource.h"
#import "GroupsCell.h"

@implementation GroupsDataSource

- (Group *)groupForIndexPath:(NSIndexPath *)indexPath
{
	return [self objectForIndexPath:indexPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (self.content.count == 0) {
		return nil;
	}
	
	Group *group = [self objectForIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
	if (group.groupId.integerValue != NSNotFound) {
		return@"Groups";
	}
	
	return @"All Tasks";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
#define GroupsCellIdentifier @"GroupsCellIdentifier"
	
	GroupsCell *cell = (GroupsCell *)[tableView dequeueReusableCellWithIdentifier:GroupsCellIdentifier];
    if (cell == nil) {
        cell = [[[GroupsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:GroupsCellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	
	Group *group = [self groupForIndexPath:indexPath];
	[cell setGroup:group];
	
    return cell;
}

@end
