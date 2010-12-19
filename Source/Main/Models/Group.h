#import <Foundation/Foundation.h>


@interface Group : NSObject {
	
}

+ (Group *)groupWithId:(NSNumber *)aGroupId
				  name:(NSString *)aName
			modifiedAt:(NSDate *)aModifiedAt;

@property (nonatomic, copy) NSNumber *groupId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSDate *modifiedAt;

@end
