#import "SettingsDataSource.h"
#import "SettingsCell.h"
#import "AccessoryViewWithImage.h"

@implementation SettingsDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (self.content.count == 0 && section != 0) {
		return nil;
	}
	
	return @"Set alerts within";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
#define SettingsCellIdentifier @"SettingsCellIdentifier"
	
	SettingsCell *cell = (SettingsCell *)[tableView dequeueReusableCellWithIdentifier:SettingsCellIdentifier];
    if (cell == nil) {
        cell = [[[SettingsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SettingsCellIdentifier] autorelease];
    }
	
	NSString *choice = [self choiceForIndexPath:indexPath];
	
	cell.textLabel.text = choice;
	
	cell.accessoryView = [AccessoryViewWithImage accessoryViewWithImageNamed:@"btn_std_arrow_off.png"
													   highlightedImageNamed:@"btn_std_arrow_touch.png" 
																  cellHeight:cell.bounds.size.height 
															   leftRightDiff:10.0];
	
    return cell;
}



@end
