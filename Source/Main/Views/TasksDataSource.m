#import "TasksDataSource.h"
#import "TimeFormatters.h"


@implementation TasksDataSource

- (NSDictionary *)taskForIndexPath:(NSIndexPath *)indexPath
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Today";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
#define TasksCellIdentifier @"TasksCellIdentifier"
	
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:TasksCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:TasksCellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
	
	NSDictionary *dictionary = [self taskForIndexPath:indexPath];
	
    cell.textLabel.text = [dictionary valueForKey:@"date"];
    cell.detailTextLabel.text = [dictionary valueForKey:@"title"];
//	
//	cell.completedButton.tag = [self tagForRow:indexPath.row];
	
    return cell;
}

@end
