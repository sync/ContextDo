#import <Foundation/Foundation.h>


@interface NSDate (Extensions) 

- (BOOL)isEarlierThanDate:(NSDate *)date;
- (BOOL)isLaterThanDate:(NSDate *)date;

@end
