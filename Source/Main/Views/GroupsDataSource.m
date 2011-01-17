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
	
	if (section == 0) {
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
	
	cell.textLabel.text = group.name;
	if (indexPath.section == 0 && [tableView numberOfRowsInSection:indexPath.section] - 1 == indexPath.row) {
		cell.imageView.image = [UIImage imageNamed:@"icon_location.png"];
	} else {
		cell.imageView.image = nil;
	}
	
	
    return cell;
}

@end
