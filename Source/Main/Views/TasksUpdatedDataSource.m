#import "TasksUpdatedDataSource.h"
#import "TasksInfoCell.h"

@implementation TasksUpdatedDataSource

- (Task *)taskForIndexPath:(NSIndexPath *)indexPath
{
	return [self objectForIndexPath:indexPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (self.content.count == 0) {
		return nil;
	}
	
	return @"Tasks Updated Today";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
#define TasksInfoCellIdentifier @"GroupsCellIdentifier"
	
	TasksInfoCell *cell = (TasksInfoCell *)[tableView dequeueReusableCellWithIdentifier:TasksInfoCellIdentifier];
    if (cell == nil) {
        cell = [[[TasksInfoCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:TasksInfoCellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	
	Task *task = [self taskForIndexPath:indexPath];
	[cell setTask:task];
	
    return cell;
}

@end
