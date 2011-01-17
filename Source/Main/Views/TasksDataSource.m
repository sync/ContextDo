#import "TasksDataSource.h"
#import "TimeFormatters.h"
#import "TasksCell.h"


@implementation TasksDataSource

- (Task *)taskForIndexPath:(NSIndexPath *)indexPath
{
	return [self objectForIndexPath:indexPath];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
#define TasksCellIdentifier @"TasksCellIdentifier"
	
	TasksCell *cell = (TasksCell *)[tableView dequeueReusableCellWithIdentifier:TasksCellIdentifier];
    if (cell == nil) {
        cell = [[[TasksCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:TasksCellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	
	Task *task = [self taskForIndexPath:indexPath];
	
	cell.textLabel.text = task.name;
	if ([AppDelegate sharedAppDelegate].hasValidCurrentLocation && task.latitude && task.longitude) {
		cell.distanceLabel.text = (task.distance / 1000.0 < 1000.0) ? [NSString stringWithFormat:@"%.1fkm", task.distance / 1000.0] : @"far away";
	} else {
		cell.distanceLabel.text = nil;
	}
	
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc]init]autorelease];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	
	[dateFormatter setDoesRelativeDateFormatting:YES];
	
	cell.detailTextLabel.text = [dateFormatter stringFromDate:task.dueAt];
	
    return cell;
}

@end
