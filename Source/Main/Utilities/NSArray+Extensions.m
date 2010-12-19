#import "NSArray+Extensions.h"
#import "NSDate-Utilities.h"

@implementation NSArray (extensions)

- (NSArray *)organizedByDayForKeyPath:(NSString *)keyPath
{
	NSMutableArray *organizedArray = [NSMutableArray array];
	
	NSInteger counter = 0;
	// Remove duplicates
	NSSet *dates = [NSSet setWithArray:[self valueForKeyPath:[NSString stringWithFormat:@"%@.dateAtStartOfDay", keyPath]]];
	for (NSDate *day in [dates.allObjects sortedArrayUsingSelector:@selector(compare:)]) {
		NSMutableArray *section = [NSMutableArray array];
		for (NSInteger i = counter; i < self.count; i++) {
			id object = [self objectAtIndex:counter];
			if ([[[object valueForKeyPath:keyPath] dateAtStartOfDay]isEqualToDate:day]) {
				[section addObject:object];
				counter=i+1;
			} else {
				counter=i;
				break;
			}
		}
		[organizedArray addObject:[NSArray arrayWithArray:section]];
	}
	
	
	return [NSArray arrayWithArray:organizedArray];
}

@end
