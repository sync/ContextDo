#import <Foundation/Foundation.h>
#import "SMModelObject.h"

@interface Task : SMModelObject {

}

@property (nonatomic, copy) NSNumber *taskId;
@property (nonatomic, copy) NSDictionary *action;
@property (nonatomic, copy) NSString *contactDetail;
@property (nonatomic, copy) NSString *contactName;
@property (nonatomic, copy) NSDate *dueAt;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSDate *updatedAt;
@property (nonatomic, copy) NSDate *createdAt;
@property (nonatomic, copy) NSNumber *groupId;
@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, copy) NSNumber *latitude;
@property (nonatomic, copy) NSNumber *longitude;
@property (nonatomic, copy) NSDate *completedAt;
@property (nonatomic, copy) NSString *info;
@property (nonatomic, copy) NSString *sourceName;
@property (nonatomic, copy) NSNumber *sourceId;

@property (nonatomic, readonly) CLLocationDistance distance;
@property (nonatomic, readonly) BOOL isClose;
@property (nonatomic, readonly) BOOL expired;
@property (nonatomic, readonly) BOOL completed;
@property (nonatomic, readonly) BOOL completedWithin24hours;
@property (nonatomic, readonly) BOOL dueToday;
@property (nonatomic, readonly) NSString *formattedContact;
@property (nonatomic, readonly) NSString *latLngString;
@property (nonatomic, readonly) BOOL isFacebook;
@property (nonatomic, readonly) BOOL editedToday;

+ (Task *)taskWithId:(NSNumber *)aTaskId
				name:(NSString *)aName
			latitude:(CLLocationDegrees)aLatitude 
		   longitude:(CLLocationDegrees)aLongitude;

@end
