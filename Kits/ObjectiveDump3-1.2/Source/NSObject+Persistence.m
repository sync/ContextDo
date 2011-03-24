#import "NSObject+Persistence.h"


@implementation  NSObject (Persistence)

- (NSString *)applicationDocumentsDirectory 
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSObject *)savedForKey:(NSString *)key
{
	if (!key) {
		return nil;
	}
	
	key = [key stringByAppendingString:@".plist"];
	
	NSString *applicationDocumentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	
	NSData *data = [NSData dataWithContentsOfFile:[applicationDocumentsDirectory stringByAppendingPathComponent:key]]; 
	if(data.length == 0) {
		return nil; 
	}
	
	return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (void)saveForKey:(NSString *)key
{
	key = [key stringByAppendingString:@".plist"];
	NSString *path = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:key];
	
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
	if(data.length > 0) {
		[data writeToFile:path atomically:NO];
	} else {
		NSFileManager *manager = [NSFileManager defaultManager];
		[manager removeItemAtPath:path error:nil];
	}
}

@end