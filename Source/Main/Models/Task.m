#import "Task.h"

@implementation Task

@synthesize taskId, action, contactDetail, contactName, dueAt, location, name;
@synthesize modifiedAt, groupId, latitude, longitude, groupName;

+ (Task *)taskWithId:(NSNumber *)aTaskId
			   title:(NSString *)aTitle
			location:(NSString *)aLocation
		  modifiedAt:(NSDate *)aModifiedAt
{
	if (!aTaskId || !aTitle) {
		return nil;
	}
	
	Task *task = [[[Task alloc]init]autorelease];
	task.taskId = aTaskId;
	task.name = aTitle;
	task.location = aLocation;
	task.modifiedAt = aModifiedAt;
	
	return task;
}

- (CLLocationDistance)distance
{
	CLLocation *taskLocation = [[[CLLocation alloc]initWithLatitude:self.latitude.doubleValue longitude:self.longitude.doubleValue]autorelease];
	return [(id)[AppDelegate sharedAppDelegate].currentLocation getDistanceFrom:taskLocation];
}

- (void)dealloc
{
	[taskId release];
	[action release];
	[contactDetail release];
	[contactName release];
	[dueAt release];
	[location release];
	[name release];
	[modifiedAt release];
	[groupId release];
	[groupName release];
	[latitude release];
	[longitude release];
	
	[super dealloc];
}


@end
