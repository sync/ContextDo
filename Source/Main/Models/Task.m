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

@end
