#import "NSDictionary+Persistence.h"


@implementation NSDictionary (Persistence)

- (NSString *)applicationDocumentsDirectory 
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSDictionary *)dictionaryWithContent:(NSArray *)content date:(NSDate *)date
{
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  content, @"content",
						  date, @"date",
						  nil];
	return dict;
}

- (id)objectUnderArray:(id)object forPathToId:(NSString *)pathToId forKey:(NSString *)key
{
	NSMutableArray *array = [NSMutableArray arrayWithArray:[self valueForKey:key]];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", pathToId, [object valueForKey:pathToId]];
	NSArray *filteredArray = [array filteredArrayUsingPredicate:predicate];
	return (filteredArray.count > 0) ? [filteredArray objectAtIndex:0] : nil;
}

- (id)filteredObjectsUnderArray:(id)object forPath:(NSString *)path forKey:(NSString *)key
{
	NSMutableArray *array = [NSMutableArray arrayWithArray:[self valueForKey:key]];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", path, object];
	return [array filteredArrayUsingPredicate:predicate];
}

- (void)setObjectUnderArray:(id)object forPathToId:(NSString *)pathToId forKey:(NSString *)key
{
	NSMutableArray *array = [NSMutableArray arrayWithArray:[self valueForKey:key]];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", pathToId, [object valueForKey:pathToId]];
	NSArray *filteredArray = [array filteredArrayUsingPredicate:predicate];
	if (filteredArray.count > 0) {
		NSInteger idx = [array indexOfObject:[filteredArray objectAtIndex:0]];
		if (idx != NSNotFound) {
			[array replaceObjectAtIndex:idx withObject:object];
		}
	} else {
		[array addObject:object];
	}
	[self setValue:array forKey:key];
}

- (void)removeObjectUnderArray:(id)object forPathToId:(NSString *)pathToId forKey:(NSString *)key
{
	NSMutableArray *array = [NSMutableArray arrayWithArray:[self valueForKey:key]];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", pathToId, [object valueForKey:pathToId]];
	NSArray *filteredArray = [array filteredArrayUsingPredicate:predicate];
	for (id foundObject in filteredArray) {
		[array removeObject:foundObject];
	}
	[self setValue:array forKey:key];
}

@end
