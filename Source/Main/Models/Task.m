#import "Task.h"
#import "NSDate-Utilities.h"

@implementation Task

@synthesize taskId, action, contactDetail, contactName, dueAt, location, name;
@synthesize updatedAt, createdAt, groupId, latitude, longitude, groupName, completedAt, info;
@synthesize sourceName, sourceId, syncId;

- (id)init
{
	self = [super init];
	if (self != nil) {
		NSDate *now = [NSDate date];
		self.createdAt = now;
		self.updatedAt = now;
	}
	return self;
}


+ (Task *)taskWithId:(NSNumber *)aTaskId
				name:(NSString *)aName
			latitude:(CLLocationDegrees)aLatitude 
		   longitude:(CLLocationDegrees)aLongitude
{
	if (!aTaskId || !aName) {
		return nil;
	}
	
	Task *task = [[[Task alloc]init]autorelease];
	task.taskId = aTaskId;
	task.name = aName;
	task.latitude = [NSNumber numberWithDouble:aLatitude];
	task.longitude = [NSNumber numberWithDouble:aLongitude];
	
	return task;
}

- (NSNumber *)taskId
{
	if (!taskId && syncId) {
		return [NSNumber numberWithInteger:-syncId.integerValue];
	}
	return taskId;
}

- (CLLocationDistance)distance
{
	CLLocation *taskLocation = [[[CLLocation alloc]initWithLatitude:self.latitude.doubleValue longitude:self.longitude.doubleValue]autorelease];
	return [(id)[AppDelegate sharedAppDelegate].currentLocation distanceFromLocation:taskLocation];
}

- (BOOL)isClose
{
	CGFloat distance = [APIServices sharedAPIServices].alertsDistanceWithin.floatValue * 1000;
	return ((!self.completed || self.completedWithin24hours) && self.distance < distance);
}

- (BOOL)expired
{
	return (!self.completed && [self.dueAt isEarlierThanDate:[NSDate date]]);
}

- (BOOL)completed
{
	return (self.completedAt != nil);
}

- (BOOL)completedWithin24hours
{
	NSDate *now = [NSDate date];
	return (self.completed && [self.completedAt hoursBeforeDate:now] < 24);
}

- (BOOL)isFacebook
{
	return [self.sourceName isEqualToString:@"facebook"];
}

- (BOOL)dueToday
{
	return (!self.completed && [self.dueAt isToday]);
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

- (NSString *)latLngString
{
	return [NSString stringWithFormat:@"%f,%f", self.latitude.doubleValue, self.longitude.doubleValue];
	
}

- (BOOL)editedToday
{
	return (!self.updatedAt && [self.updatedAt isToday]);
}

@end
