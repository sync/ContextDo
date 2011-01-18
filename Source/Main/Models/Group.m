#import "Group.h"


@implementation Group

@synthesize groupId, name, createdAt, updatedAt, position, expiredCount, dueCount, userId;

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

- (BOOL)isEqual:(id)anObject
{
	return [self.groupId isEqual:[anObject groupId]];
}

- (NSUInteger)hash
{
	return [self.groupId hash];
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
	[userId release];
	[position release];
	[expiredCount release];
	[dueCount release];
	[groupId release];
	[name release];
	[updatedAt release];
	[createdAt release];
	
	[super dealloc];
}


@end
