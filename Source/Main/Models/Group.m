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

+ (Group *)groupWithId:(NSNumber *)aGroupId
				  name:(NSString *)aName
			  position:(NSNumber *)aPosition
{
	if (!aGroupId || !aName) {
		return nil;
	}
	
	Group *group = [Group groupWithId:aGroupId name:aName];
	group.name = aName;
	
	return group;
}

@end
