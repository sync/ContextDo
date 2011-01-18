#import <Foundation/Foundation.h>


@interface Group : NSObject {
	
}

@property (nonatomic, copy) NSNumber *groupId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSDate *updatedAt;
@property (nonatomic, copy) NSDate *createdAt;
@property (nonatomic, copy) NSNumber *position;

+ (Group *)groupWithId:(NSNumber *)aGroupId
				  name:(NSString *)aName;

@end
