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
	NSMutableArray *components = [NSMutableArray arrayWithObjects:
								  @"",
								  @"",
								  @"",
								  nil];
	
	NSString *placeholder = [self objectForIndexPath:indexPath];
	if ([placeholder isEqualToString:PlaceNamePlaceHolder]) {
		[components insertObject:value atIndex:0];
	} else if ([placeholder isEqualToString:StreetPlaceHolder]) {
		[components insertObject:value atIndex:1];
	} else if ([placeholder isEqualToString:SuburbPlaceHolder]) {
		[components insertObject:value atIndex:1];
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
