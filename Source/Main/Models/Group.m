#import "Group.h"


@implementation Group

@synthesize groupId, name, createdAt, updatedAt, position, expiredCount, dueCount, userId;
@synthesize taskWithin;

+ (Group *)groupWithId:(NSNumber *)aGroupId
				  name:(NSString *)aName
{
	if (!aGroupId || !aName) {
		return nil;
	}
	
	Group *group = [[[Group alloc]init]autorelease];
	group.groupId = aGroupId;
	group.name = aName;
	
	return group;
}

+ (Group *)groupWithName:(NSString *)aName
			  position:(NSNumber *)aPosition
{
	if (!aName || !aPosition) {
		return nil;
	}
	
	Group *group = [[[Group alloc]init]autorelease];
	group.name = aName;
	group.position = aPosition;
	
	return group;
}

@end
