#import "TaskLocationDataSource.h"


@implementation TaskLocationDataSource

- (NSString *)valueForIndexPath:(NSIndexPath *)indexPath;
{
	NSArray *components = [self.tempTask.location componentsSeparatedByString:@", "];
	
	if (components.count != 3) {
		return nil;
	}
	
	NSString *placeholder = [self objectForIndexPath:indexPath];
	NSString *value = nil;
	if ([placeholder isEqualToString:PlaceNamePlaceHolder]) {
		value = [components objectAtIndex:0];
	} else if ([placeholder isEqualToString:StreetPlaceHolder]) {
		value = [components objectAtIndex:1];
	} else if ([placeholder isEqualToString:SuburbPlaceHolder]) {
		value = [components objectAtIndex:2];
	}
	
	return value;
}

- (void)setValue:(NSString *)value forIndexPath:(NSIndexPath *)indexPath
{
	if (!value) {
		self.tempTask.location = nil;
		return;
	}
	
	NSMutableArray *components = [NSMutableArray arrayWithObjects:
								  @"",
								  @"",
								  @"",
								  nil];
	
	for (NSInteger i = 0; i<3; i++) {
		NSString *previousValue = [self valueForIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
		if (previousValue) {
			[components replaceObjectAtIndex:i withObject:previousValue];
		}
	}
	
	NSString *placeholder = [self objectForIndexPath:indexPath];
	if ([placeholder isEqualToString:PlaceNamePlaceHolder]) {
		[components  replaceObjectAtIndex:0 withObject:value];
	} else if ([placeholder isEqualToString:StreetPlaceHolder]) {
		[components  replaceObjectAtIndex:1 withObject:value];
	} else if ([placeholder isEqualToString:SuburbPlaceHolder]) {
		[components  replaceObjectAtIndex:2 withObject:value];
	}
	
	self.tempTask.location = [components componentsJoinedByString:@", "];
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
