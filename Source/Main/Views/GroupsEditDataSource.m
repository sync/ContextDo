#import "GroupsEditDataSource.h"
#import "GroupsEditCell.h"

@implementation GroupsEditDataSource

@synthesize delegate;

- (Group *)groupForIndexPath:(NSIndexPath *)indexPath
{
	return [self objectForIndexPath:indexPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Groups";
}

#define TagDiff 108097

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
	GroupsEditCell *cell = (GroupsEditCell *)[tableView dequeueReusableCellWithIdentifier:nil];
    if (cell == nil) {
        cell = [[[GroupsEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil] autorelease];
    }
	
	Group *group = [self groupForIndexPath:indexPath];
	
	cell.textField.text = group.name;
	cell.textField.tag = [self tagForRow:indexPath.row];
	
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return TRUE;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return TRUE;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.delegate groupsEditDataSource:self commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	[self.delegate groupsEditDataSource:self  moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
}

@end
