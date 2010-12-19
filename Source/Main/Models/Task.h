#import <Foundation/Foundation.h>

@interface Task : NSObject {

}

@property (nonatomic, copy) NSNumber *taskId;
@property (nonatomic, copy) NSDictionary *action;
@property (nonatomic, copy) NSString *contactDetail;
@property (nonatomic, copy) NSString *contactName;

@property (nonatomic, copy) NSDate *dueAt;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSDate *modifiedAt;
@property (nonatomic, copy) NSNumber *groupId;
@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, copy) NSNumber *latitude;
@property (nonatomic, copy) NSNumber *longitude;

@property (nonatomic, readonly) CLLocationDistance distance;

+ (Task *)taskWithId:(NSNumber *)aTaskId
			   title:(NSString *)aTitle
			location:(NSString *)location
		  modifiedAt:(NSDate *)aModifiedAt;

@end
