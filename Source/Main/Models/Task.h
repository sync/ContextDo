#import "_Task.h"

@interface Task : _Task {}

@property (nonatomic, readonly) CLLocationDistance distance;
@property (nonatomic, readonly) BOOL isClose;
@property (nonatomic, readonly) BOOL expired;
@property (nonatomic, readonly) BOOL completed;
@property (nonatomic, readonly) BOOL completedWithin24hours;
@property (nonatomic, readonly) BOOL dueToday;
@property (nonatomic, readonly) NSString *formattedContact;
@property (nonatomic, readonly) NSString *latLngString;
@property (nonatomic, readonly) BOOL isFacebook;

+ (Task *)taskWithName:(NSString *)aName
              latitude:(CLLocationDegrees)aLatitude 
             longitude:(CLLocationDegrees)aLongitude;

@end
