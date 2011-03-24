#import <Foundation/Foundation.h>


@interface NSDictionary (Persistence)

+ (NSDictionary *)dictionaryWithContent:(NSArray *)content date:(NSDate *)date;

- (id)objectUnderArray:(id)object forPathToId:(NSString *)pathToId forKey:(NSString *)key;
- (id)filteredObjectsUnderArray:(id)object forPath:(NSString *)path forKey:(NSString *)key;
- (void)setObjectUnderArray:(id)object forPathToId:(NSString *)pathToId forKey:(NSString *)key;
- (void)removeObjectUnderArray:(id)object forPathToId:(NSString *)pathToId forKey:(NSString *)key;

@end
