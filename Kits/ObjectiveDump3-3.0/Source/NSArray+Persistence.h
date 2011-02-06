#import <Foundation/Foundation.h>


@interface NSArray (Persistence)

+ (NSDictionary *)savedArrayForKey:(NSString *)key;
- (void)saveArrayForKey:(NSString *)key;

@end
