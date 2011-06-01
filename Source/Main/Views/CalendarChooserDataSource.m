#import "CalendarChooserDataSource.h"


@implementation CalendarChooserDataSource

@synthesize selectedCalendar;

- (EKCalendar *)calendarForIndexPath:(NSIndexPath *)indexPath
{
	return [self objectForIndexPath:indexPath];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
#define CalendarChooserCellIdentifier @"CalendarChooserCellIdentifier"
	
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CalendarChooserCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CalendarChooserCellIdentifier] autorelease];
    }
	
	EKCalendar *calendar = [self calendarForIndexPath:indexPath];
	
	if ([calendar isEqual:self.selectedCalendar]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
    
    cell.textLabel.text = calendar.title;
	
    return cell;
}

- (void)dealloc
{
    [selectedCalendar release];
    
    [super dealloc];
}

@end
