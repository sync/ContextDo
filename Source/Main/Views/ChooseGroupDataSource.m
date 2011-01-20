#import "ChooseGroupDataSource.h"


@implementation ChooseGroupDataSource

- (Group *)groupForIndexPath:(NSIndexPath *)indexPath
{
	return [self objectForIndexPath:indexPath];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
#define ChooseGroupCellIdentifier @"ChooseGroupCellIdentifier"
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ChooseGroupCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ChooseGroupCellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
    }
	
	Group *group = [self groupForIndexPath:indexPath];
	cell.textLabel.text = group.name;
	
    return cell;
}


@end
