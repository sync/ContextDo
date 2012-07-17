#import <Foundation/Foundation.h>
#import "BaseASIServices.h"

@interface APIServices : BaseASIServices {

}

+ (APIServices *)sharedAPIServices;

- (void)refreshGroups;
- (void)addGroup:(Group *)group;
- (void)updateGroup:(Group *)group;
- (void)deleteGroup:(Group *)group;
- (void)syncGroups;

- (void)refreshTasksWithGroupId:(NSNumber *)groupId;
- (void)refreshTasksWithDue:(NSString *)due;
- (void)refreshTasksDueToday;
- (void)refreshTasksWithLatitude:(CLLocationDegrees)latitude
					   longitude:(CLLocationDegrees)longitude;
- (void)refreshTasksWithQuery:(NSString *)query;
- (void)refreshTasksEdited;
- (void)addTask:(Task *)task;
- (void)updateTask:(Task *)task;
- (void)deleteTask:(Task *)task;

@end
