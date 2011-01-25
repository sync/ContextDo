#import "TasksCalendarDataSource.h"


@implementation TasksCalendarDataSource

- (Task *)taskForIndexPath:(NSIndexPath *)indexPath
{
	return [self objectForIndexPath:indexPath];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
#define TasksCalendarCellIdentifier @"TasksCalendarCellIdentifier"
	
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:TasksCalendarCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TasksCalendarCellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.textLabel.textColor = [UIColor whiteColor];
    }
	
	Task *task = [self taskForIndexPath:indexPath];
	cell.textLabel.text = task.name;
	
    return cell;
}

@end
