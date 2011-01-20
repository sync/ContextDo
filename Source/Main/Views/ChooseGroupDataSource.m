#import "ChooseGroupDataSource.h"
#import "TaskEditCell.h"

@implementation ChooseGroupDataSource

@synthesize task;

- (Group *)groupForIndexPath:(NSIndexPath *)indexPath
{
	return [self objectForIndexPath:indexPath];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
#define TaskEditCellIdentifer @"TaskEditCellIdentifer"
	
	TaskEditCell *cell = (TaskEditCell *)[tableView dequeueReusableCellWithIdentifier:TaskEditCellIdentifer];
    if (cell == nil) {
        cell = [[[TaskEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:TaskEditCellIdentifer] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
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
