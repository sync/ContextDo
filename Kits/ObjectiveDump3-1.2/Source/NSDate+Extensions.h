#import <Foundation/Foundation.h>

@interface NSDate (Extensions)

+ (NSString *)stringForDisplayFromDate:(NSDate *)date;
+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed;
+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed alwaysShowTime:(BOOL)showTime;

- (NSString *)getUTCDateWithformat:(NSString *)format;

@end
