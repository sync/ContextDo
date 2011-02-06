#import "NSDate+Extensions.h"
#import "NSDate-Utilities.h"

@implementation NSDate (Extensions)

// ripoff https://github.com/billymeltdown/nsdate-helper/network but with fixes

+ (NSString *)stringForDisplayFromDate:(NSDate *)date 
{
	return [self stringForDisplayFromDate:date prefixed:NO];
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed 
{
	return [self stringForDisplayFromDate:date prefixed:NO alwaysShowTime:FALSE];
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed alwaysShowTime:(BOOL)showTime
{
	/* 
	 * if the date is in today, display 12-hour time with meridian,
	 * if it is within the last 7 days, display weekday name (Friday)
	 * if within the calendar year, display as Jan 23
	 * else display as Nov 11, 2008
	 */
	
	NSDateFormatter *displayFormatter = [[[NSDateFormatter alloc] init]autorelease];
	NSString *displayString = nil;
	
	// comparing against midnight
	if ([date isToday]) {
		if (prefixed) {
			[displayFormatter setDateFormat:@"'at' h:mm a"]; // at 11:30 am
		} else {
			[displayFormatter setDateFormat:@"h:mm a"]; // 11:30 am
		}
	} else {
		if ([date isThisWeek]) {
			[displayFormatter setDateFormat:@"EEEE"]; // Tuesday
		} else {
			if ([date isThisYear]) {
				[displayFormatter setDateFormat:@"MMM d"];
			} else {
				[displayFormatter setDateFormat:@"MMM d, yyyy"];
			}
		}
		if (prefixed) {
			NSString *dateFormat = [displayFormatter dateFormat];
			NSString *prefix = @"'on' ";
			[displayFormatter setDateFormat:[prefix stringByAppendingString:dateFormat]];
		}
		if (showTime) {
			NSString *dateFormat = [displayFormatter dateFormat];
			NSString *time = @" 'at' h:mma";
			[displayFormatter setDateFormat:[dateFormat stringByAppendingString:time]];
		}
	}
	
	// use display formatter to return formatted date string
	displayString = [displayFormatter stringFromDate:date];
	return displayString;
}

//http://stackoverflow.com/questions/2615833/objective-c-setting-nsdate-to-current-utc

- (NSString *)getUTCDateWithformat:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]autorelease];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:format];
    NSString *dateString = [dateFormatter stringFromDate:self];
    return dateString;
}

@end
