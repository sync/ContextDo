#import "Group.h"


@implementation Group

@synthesize name, modifiedAt, groupId;

+ (Group *)groupWithId:(NSNumber *)aGroupId
				  name:(NSString *)aName
			modifiedAt:(NSDate *)aModifiedAt
{
	if (!aGroupId || !aName) {
		return nil;
	}
	
	Group *group = [[[Group alloc]init]autorelease];
	group.groupId = aGroupId;
	group.name = aName;
	group.modifiedAt = aModifiedAt;
	
	return group;
}

- (void)dealloc
{
	[groupId release];
	[name release];
	[modifiedAt release];
	
	[super dealloc];
}


@end
