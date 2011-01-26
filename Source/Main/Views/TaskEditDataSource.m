#import "TaskEditDataSource.h"
#import "TaskEditCell.h"
#import "NSDate+Extensions.h"
#import "AccessoryViewWithImage.h"

@implementation TaskEditDataSource

@synthesize tempTask;

- (NSString *)valueForIndexPath:(NSIndexPath *)indexPath;
{
	NSString *placeholder = [self objectForIndexPath:indexPath];
	NSString *value = nil;
	if ([placeholder isEqualToString:TitlePlaceholder]) {
		value = self.tempTask.name;
	} else if ([placeholder isEqualToString:InfoPlaceholder]) {
		value = self.tempTask.info;
	} else if ([placeholder isEqualToString:LocationPlaceholder]) {
		value = self.tempTask.location;
	} else if ([placeholder isEqualToString:AddContactPlaceholder]) {
		value = self.tempTask.formattedContact;
	} else if ([placeholder isEqualToString:TimePlaceholder]) {
		value = [NSDate stringForDisplayFromDate:self.tempTask.dueAt prefixed:NO alwaysShowTime:TRUE];
	} else if ([placeholder isEqualToString:AlertsPlaceholder]) {
		
	} else if ([placeholder isEqualToString:GroupPlaceholder]) {
		value = self.tempTask.groupName;
	}
	
	return value;
}

- (void)setValue:(NSString *)value forIndexPath:(NSIndexPath *)indexPath
{
	NSString *placeholder = [self objectForIndexPath:indexPath];
	if ([placeholder isEqualToString:TitlePlaceholder]) {
		self.tempTask.name = value;
	} else if ([placeholder isEqualToString:InfoPlaceholder]) {
		self.tempTask.info = value;
	} else if ([placeholder isEqualToString:LocationPlaceholder]) {
		self.tempTask.location = value;
	} else if ([placeholder isEqualToString:AddContactPlaceholder]) {
		NSArray *component = [value componentsSeparatedByString:@" - "];
		if (component.count == 2) {
			self.tempTask.contactName = [component objectAtIndex:0];
			self.tempTask.contactDetail = [component objectAtIndex:1];
		} else {
			self.tempTask.contactName = value;
		}
	} else if ([placeholder isEqualToString:AlertsPlaceholder]) {
		// todo
	}
}

- (NSInteger)tagForIndexPath:(NSIndexPath *)indexPath
{
	return indexPath.section * 100000 + indexPath.row * 10;
}

- (NSIndexPath *)indexPathForTag:(NSInteger)tag
{
	NSInteger section = tag / 100000;
	NSInteger modulo = tag % 100000;
	NSInteger row = modulo / 10;
	
	return [NSIndexPath indexPathForRow:row inSection:section];
}

- (BOOL)isIndexPathInput:(NSIndexPath *)indexPath
{
	NSString *placeholder = [self objectForIndexPath:indexPath];
	return ([placeholder isEqualToString:TitlePlaceholder] ||
			[placeholder isEqualToString:LocationPlaceholder] ||
			[placeholder isEqualToString:AddContactPlaceholder] ||
			[placeholder isEqualToString:AlertsPlaceholder]);
}

- (BOOL)isIndexPathInputMulti:(NSIndexPath *)indexPath;
{
	NSString *placeholder = [self objectForIndexPath:indexPath];
	return [placeholder isEqualToString:InfoPlaceholder];
}

- (BOOL)hasNoteEdit:(NSIndexPath *)indexPath
{
	NSString *placeholder = [self objectForIndexPath:indexPath];
	return [placeholder isEqualToString:TitlePlaceholder];
}

- (BOOL)hasTargetButton:(NSIndexPath *)indexPath
{
	NSString *placeholder = [self objectForIndexPath:indexPath];
	return [placeholder isEqualToString:LocationPlaceholder];
}

- (BOOL)hasDetailDisclosure:(NSIndexPath *)indexPath
{
	NSString *placeholder = [self objectForIndexPath:indexPath];
	return ([placeholder isEqualToString:AddContactPlaceholder]);
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	TaskEditCell *cell = (TaskEditCell *)[tableView dequeueReusableCellWithIdentifier:nil];
    if (cell == nil) {
        cell = [[[TaskEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
    }
	
	NSString *value = [self valueForIndexPath:indexPath];
	NSString *placeholder = [self objectForIndexPath:indexPath];
	
	if ([self isIndexPathInput:indexPath]) {
		cell.textField.placeholder = placeholder;
		cell.textField.text = value;
		cell.textField.tag = [self tagForIndexPath:indexPath];
		if ([self hasDetailDisclosure:indexPath]) {
			cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		} else if ([self hasNoteEdit:indexPath]) {
			UIButton *button = [[[UIButton alloc] initWithFrame:CGRectZero]autorelease];
			
			UIImage *image = [UIImage imageNamed:@"icon_notes.png"];
			[button setBackgroundImage:image forState:UIControlStateNormal];
			
			button.frame = CGRectMake(button.frame.origin.x, 
									  button.frame.origin.y, 
									  image.size.width, 
									  image.size.height);
			button.tag = [self tagForIndexPath:indexPath];
			cell.accessoryView = button;
		} else if ([self hasTargetButton:indexPath]) {
			UIButton *button = [[[UIButton alloc] initWithFrame:CGRectZero]autorelease];
			
			UIImage *image = [UIImage imageNamed:@"icon_locateTouch.png"];
			[button setBackgroundImage:image forState:UIControlStateNormal];
			UIImage *backGroundimage = [UIImage imageNamed:@"icon_locate.png"];
			[button setBackgroundImage:backGroundimage forState:UIControlStateHighlighted];
			
			button.frame = CGRectMake(button.frame.origin.x, 
									  button.frame.origin.y, 
									  image.size.width, 
									  image.size.height);
			button.tag = [self tagForIndexPath:indexPath];
			cell.accessoryView = button;
		} else {
			cell.accessoryView = nil;
		}
	} else if ([self isIndexPathInputMulti:indexPath]) {
		cell.textView.text = value;
		cell.textView.tag = [self tagForIndexPath:indexPath];
		cell.accessoryView = nil;
	} else {
		cell.textLabel.text = (value) ? value : placeholder;
		cell.accessoryView = [AccessoryViewWithImage accessoryViewWithImageNamed:@"btn_std_arrow_off.png"
														   highlightedImageNamed:@"btn_std_arrow_touch.png" 
																	  cellHeight:cell.bounds.size.height 
																   leftRightDiff:10.0];
	}
	
    return cell;
}

- (void)dealloc
{
	[tempTask release];
	
	[super dealloc];
}

@end
