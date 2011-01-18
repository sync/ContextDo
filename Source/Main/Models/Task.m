#import "Task.h"
#import "NSDate-Utilities.h"

@implementation Task

@synthesize taskId, action, contactDetail, contactName, dueAt, location, name;
@synthesize updatedAt, createdAt, groupId, latitude, longitude, groupName, completedAt;

+ (Task *)taskWithId:(NSNumber *)aTaskId
				name:(NSString *)aName
			location:(NSString *)aLocation;
{
	if (!aTaskId || !aName) {
		return nil;
	}
	
	Task *task = [[[Task alloc]init]autorelease];
	task.taskId = aTaskId;
	task.name = aName;
	task.location = aLocation;
	
	return task;
}

- (CLLocationDistance)distance
{
	CLLocation *taskLocation = [[[CLLocation alloc]initWithLatitude:self.latitude.doubleValue longitude:self.longitude.doubleValue]autorelease];
	return [(id)[AppDelegate sharedAppDelegate].currentLocation getDistanceFrom:taskLocation];
}

- (BOOL)expired
{
	return (!self.completed && [self.dueAt isEarlierThanDate:[NSDate date]]);
}

- (BOOL)completed
{
	return (self.completedAt != nil);
}

- (BOOL)isEqual:(id)anObject
{
	return [self.taskId isEqual:[anObject taskId]];
}

- (NSUInteger)hash
{
	return [self.taskId hash];
}

- (NSString *)description
{
	return [NSString stringWithFormat:
			@"taskId:%@, name:%@, createdAt:%@, updatedAt:%@, completedAt:%@, action:%@, contactDetail:%@, contactName:%@, "
			@"dueAt:%@, location:%@, groupId:%@, groupName:%@, latitude:%@, longitude:%@",
			self.taskId, self.name, self.createdAt, self.updatedAt, self.completedAt, self.action, self.contactDetail,  self.contactName,
			self.dueAt, self.location, self.groupId, self.groupName, self.latitude, self.longitude
			];
}

- (void)dealloc
{
	[taskId release];
	[name release];
	[createdAt release];
	[updatedAt release];
	[completedAt release];
	[action release];
	[contactDetail release];
	[contactName release];
	[dueAt release];
	[location release];
	[groupId release];
	[groupName release];
	[latitude release];
	[longitude release];
	
	[super dealloc];
}


@end
