#import "GroupsEditDataSource.h"


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

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
#define GroupsEditCellIdentifier @"GroupsEditCellIdentifier"
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GroupsEditCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:GroupsEditCellIdentifier] autorelease];
    }
	
	Group *group = [self groupForIndexPath:indexPath];
	
	cell.textLabel.text = group.name;
	
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
