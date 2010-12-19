#import "GroupsDataSource.h"


@implementation GroupsDataSource

- (Group *)groupForIndexPath:(NSIndexPath *)indexPath
{
	return [self objectForIndexPath:indexPath];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
#define GroupsCellIdentifier @"GroupsCellIdentifier"
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GroupsCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:GroupsCellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	
	Group *group = [self groupForIndexPath:indexPath];
	
	cell.textLabel.text = group.name;
	
    return cell;
}

@end
