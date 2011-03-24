#import <Foundation/Foundation.h>


@interface NSObject (Persistence)

+ (NSObject *)savedForKey:(NSString *)key;
- (void)saveForKey:(NSString *)key;

@end