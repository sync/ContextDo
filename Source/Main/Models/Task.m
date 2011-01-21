#import "Task.h"
#import "NSDate-Utilities.h"

@implementation Task

@synthesize taskId, action, contactDetail, contactName, dueAt, location, name;
@synthesize updatedAt, createdAt, groupId, latitude, longitude, groupName, completedAt, info;

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

- (BOOL)isClose
{
	return (self.distance < 1000); // todo get this value from the user's default
}

- (BOOL)expired
{
	return (!self.completed && [self.dueAt isEarlierThanDate:[NSDate date]]);
}

- (BOOL)completed
{
	return (self.completedAt != nil);
}

- (NSString *)formattedContact
{
	NSString *string = @"";
	NSString *separator = @" - ";
	if (self.contactName.length > 0) {
		string = [string stringByAppendingFormat:@"%@", self.contactName];
	}
	if (self.contactDetail.length > 0) {
		if (string.length == 0) {
			string = @"n/a";
		}
		string = [string stringByAppendingFormat:@"%@%@", separator, self.contactDetail];
	}
	
	return (string.length > 0) ? string : nil;
}

@end
