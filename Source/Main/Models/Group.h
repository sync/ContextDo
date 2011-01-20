#import <Foundation/Foundation.h>
#import "SMModelObject.h"

@interface Group : SMModelObject {
	
}

@property (nonatomic, copy) NSNumber *groupId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSDate *updatedAt;
@property (nonatomic, copy) NSDate *createdAt;
@property (nonatomic, copy) NSNumber *position;
@property (nonatomic, copy) NSNumber *expiredCount;
@property (nonatomic, copy) NSNumber *dueCount;
@property (nonatomic, copy) NSNumber *userId;

@property (nonatomic) BOOL taskWithin;

+ (Group *)groupWithId:(NSNumber *)aGroupId
				  name:(NSString *)aName;

@end
