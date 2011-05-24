#import "CalendarChooserDataSource.h"


@implementation CalendarChooserDataSource

@synthesize selectedCalendarName;

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
#define CalendarChooserCellIdentifier @"CalendarChooserCellIdentifier"
	
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CalendarChooserCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CalendarChooserCellIdentifier] autorelease];
    }
	
	NSString *choice = [self choiceForIndexPath:indexPath];
	
	if ([choice isEqualToString:self.selectedCalendarName]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
    
    cell.textLabel.text = choice;
	
    return cell;
}

- (void)dealloc
{
    [selectedCalendarName release];
    
    [super dealloc];
}

@end
