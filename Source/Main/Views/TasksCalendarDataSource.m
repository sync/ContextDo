#import "TasksCalendarDataSource.h"
#import "TasksCalendarCell.h"

@implementation TasksCalendarDataSource

- (Task *)taskForIndexPath:(NSIndexPath *)indexPath
{
	return [self objectForIndexPath:indexPath];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
#define TasksCalendarCellIdentifier @"TasksCalendarCellIdentifier"
	
	TasksCalendarCell *cell = (TasksCalendarCell *)[tableView dequeueReusableCellWithIdentifier:TasksCalendarCellIdentifier];
    if (cell == nil) {
        cell = [[[TasksCalendarCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TasksCalendarCellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.textLabel.textColor = [UIColor whiteColor];
    }
	
	Task *task = [self taskForIndexPath:indexPath];
	[cell setTask:task];
	
    return cell;
}

@end
