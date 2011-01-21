#import "TaskDatePickerDataSource.h"
#import "TaskEditCell.h"

@implementation TaskDatePickerDataSource

@synthesize task;

- (NSString *)stringForIndexPath:(NSIndexPath *)indexPath
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
		cell.textField.enabled = FALSE;
    }
	
	NSString *string = [self stringForIndexPath:indexPath];
	cell.textLabel.text = string;
	
    return cell;
}

- (void)dealloc
{
	[task release];
	
	[super dealloc];
}

@end
