#import "ChoicesListDataSource.h"

@implementation ChoicesListDataSource

#pragma mark -
#pragma mark Content

- (id)initWitChoicesList:(NSArray *)choicesList
{
    if ((self = [super init])) {
        [self.content addObjectsFromArray:choicesList];
    }
    return self;
}

- (NSString *)choiceForIndexPath:(NSIndexPath *)indexPath
{
	return [self objectForIndexPath:indexPath];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
#define ChoicesCellIdentifier @"ChoicesCellIdentifier"
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ChoicesCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ChoicesCellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	
	NSString *choice = [self choiceForIndexPath:indexPath];
	
	cell.textLabel.text = choice;
	
    return cell;
}

@end
