#import "Task.h"
#import "NSDate-Utilities.h"

@implementation Task

+ (Task *)taskWithName:(NSString *)aName
              latitude:(CLLocationDegrees)aLatitude 
             longitude:(CLLocationDegrees)aLongitude
{
	if (!aName) {
		return nil;
	}
	
	Task *task = [[[Task alloc]init]autorelease];
	task.name = aName;
	task.latitude = [NSNumber numberWithDouble:aLatitude];
	task.longitude = [NSNumber numberWithDouble:aLongitude];
	
	return task;
}

- (CLLocationDistance)distance
{
	CLLocation *taskLocation = [[[CLLocation alloc]initWithLatitude:self.latitude.doubleValue longitude:self.longitude.doubleValue]autorelease];
	return [(id)[AppDelegate sharedAppDelegate].currentLocation distanceFromLocation:taskLocation];
}

- (BOOL)isClose
{
	CGFloat distance = 0.0; // todo
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

@end
