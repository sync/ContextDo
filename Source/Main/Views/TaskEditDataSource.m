#import "TaskEditDataSource.h"
#import "TaskEditCell.h"
#import "NSDate+Extensions.h"

@implementation TaskEditDataSource

@synthesize tempTask;

- (NSString *)valueForIndexPath:(NSIndexPath *)indexPath;
{
	NSString *placeholder = [self objectForIndexPath:indexPath];
	NSString *value = nil;
	if ([placeholder isEqualToString:TitlePlaceHolder]) {
		
	} else if ([placeholder isEqualToString:LocationPlaceHolder]) {
		
	} else if ([placeholder isEqualToString:AddContactPlaceHolder]) {
		
	} else if ([placeholder isEqualToString:TimePlaceHolder]) {
		value = [NSDate stringForDisplayFromDate:self.tempTask.dueAt];
	} else if ([placeholder isEqualToString:AlertsPlaceHolder]) {
		
	} else if ([placeholder isEqualToString:GroupPlaceHolder]) {
		value = self.tempTask.groupName;
	}
	
	return value;
}

- (void)setValue:(NSString *)value forIndexPath:(NSIndexPath *)indexPath
{
	NSString *placeholder = [self objectForIndexPath:indexPath];
	if ([placeholder isEqualToString:TitlePlaceHolder]) {
		self.tempTask.name = value;
	} else if ([placeholder isEqualToString:LocationPlaceHolder]) {
		self.tempTask.location = value;
	} else if ([placeholder isEqualToString:AddContactPlaceHolder]) {
		// todo
	} else if ([placeholder isEqualToString:AlertsPlaceHolder]) {
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
	return !([placeholder isEqualToString:TimePlaceHolder] ||
			[placeholder isEqualToString:GroupPlaceHolder]);
}

- (BOOL)hasDetailDisclosure:(NSIndexPath *)indexPath
{
	NSString *placeholder = [self objectForIndexPath:indexPath];
	return ([placeholder isEqualToString:LocationPlaceHolder] ||
			[placeholder isEqualToString:AddContactPlaceHolder]);
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
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;	
		}
	} else {
		cell.textLabel.text = (value) ? value : placeholder;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
    return cell;
}

- (void)dealloc
{
	[tempTask release];
	
	[super dealloc];
}

@end
