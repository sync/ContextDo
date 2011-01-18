#import "TasksDataSource.h"
#import "TimeFormatters.h"
#import "TasksCell.h"


@implementation TasksDataSource

- (Task *)taskForIndexPath:(NSIndexPath *)indexPath
{
	return [self objectForIndexPath:indexPath];
}

#define TagDiff 908096

- (NSInteger)tagForRow:(NSInteger)row
{
	return row + TagDiff;
}

- (NSInteger)rowForTag:(NSInteger)tag
{
	return tag - TagDiff;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
#define TasksCellIdentifier @"TasksCellIdentifier"
	
	TasksCell *cell = (TasksCell *)[tableView dequeueReusableCellWithIdentifier:TasksCellIdentifier];
    if (cell == nil) {
        cell = [[[TasksCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:TasksCellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
	
	Task *task = [self taskForIndexPath:indexPath];
	[cell setTask:task];
	
	cell.completedButton.tag = [self tagForRow:indexPath.row];
	
    return cell;
}

@end
