#import "Group.h"


@implementation Group

@synthesize groupId, name, createdAt, updatedAt;

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

- (NSString *)description
{
	return [NSString stringWithFormat:
			@"groupId:%@, name:%@, createdAt:%@, updatedAt:%@",
			self.groupId, self.name, self.createdAt, self.updatedAt 
			];
}

- (void)dealloc
{
	[groupId release];
	[name release];
	[updatedAt release];
	[createdAt release];
	
	[super dealloc];
}


@end
