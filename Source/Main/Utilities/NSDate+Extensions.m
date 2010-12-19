#import "NSDate+Extensions.h"


@implementation NSDate (Extensions)

// Found here: http://arstechnica.com/apple/guides/2010/03/how-to-real-world-dates-with-the-iphone-sdk.ars/2

- (BOOL)isEarlierThanDate:(NSDate *)date
{
	return ([self earlierDate:date] == self);
}

- (BOOL)isLaterThanDate:(NSDate *)date
{
	return ([self laterDate:date] == self);
}

@end
