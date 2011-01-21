#import "TaskContactDataSource.h"
#import "TaskEditCell.h"

@implementation TaskContactDataSource

- (NSString *)valueForIndexPath:(NSIndexPath *)indexPath;
{
	NSString *placeholder = [self objectForIndexPath:indexPath];
	NSString *value = nil;
	if ([placeholder isEqualToString:ContactNamePlaceHolder]) {
		value = self.tempTask.contactName;
	} else if ([placeholder isEqualToString:ContactDetailPlaceHolder]) {
		value = self.tempTask.contactDetail;
	}
	
	return value;
}

- (void)setValue:(NSString *)value forIndexPath:(NSIndexPath *)indexPath
{
	NSString *placeholder = [self objectForIndexPath:indexPath];
	if ([placeholder isEqualToString:ContactNamePlaceHolder]) {
		self.tempTask.contactName = value;
	} else if ([placeholder isEqualToString:ContactDetailPlaceHolder]) {
		self.tempTask.contactName = value;
	}
}

- (BOOL)isIndexPathInput:(NSIndexPath *)indexPath
{
	return TRUE;
}

- (BOOL)hasDetailDisclosure:(NSIndexPath *)indexPath
{
	return FALSE;
}

@end
