#import "ChooseGroupDataSource.h"


@implementation ChooseGroupDataSource

@synthesize task;

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
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
	
	Group *group = [self groupForIndexPath:indexPath];
	cell.textLabel.text = group.name;
	
	if ([self.task.groupId isEqual:group.groupId]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
    return cell;
}

- (void)dealloc
{
	[task release];
	
	[super dealloc];
}

@end
