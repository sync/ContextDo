#import <Foundation/Foundation.h>
#import "BaseASIServices.h"
#import "NSDictionary+Persistence.h"

@interface APIServices : BaseASIServices {

}

+ (APIServices *)sharedAPIServices;

@property (nonatomic, assign) NSString *apiToken;
@property (nonatomic, assign) NSString *username;
@property (nonatomic, assign) NSString *password;
- (void)loginWithUsername:(NSString *)username password:(NSString *)password;
- (void)registerWithUsername:(NSString *)username password:(NSString *)password;
- (void)resetPasswordWithUsername:(NSString *)username;

- (void)refreshGroups;
- (void)refreshGroups;
- (void)addGroup:(Group *)group;
- (void)updateGroup:(Group *)group;
- (void)deleteGroup:(Group *)group;

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

- (void)refreshUser;
- (void)updateUser:(User *)user;
@property (nonatomic, assign) NSNumber *alertsDistanceWithin;
- (CGFloat)alertsDistancKmToSliderValue:(CGFloat)value;
- (CGFloat)sliderValueToAlertsDistancKm:(CGFloat)value;

@property (nonatomic, readonly) NSMutableDictionary *groupsDict;
- (void)saveGroupsDict;
@property (nonatomic, readonly) NSMutableDictionary *tasksWithGroupIdDict;
- (void)saveTasksWithGroupId;
@property (nonatomic, readonly) NSMutableDictionary *tasksDueTodayDict;
- (void)saveTasksDueToday;
@property (nonatomic, readonly) NSMutableDictionary *tasksWithDueDict;
- (void)saveTasksWithDue;
@property (nonatomic, readonly) NSMutableDictionary *tasksWithLatitudeDict;
- (void)saveTasksWithLatitude;
@property (nonatomic, readonly) NSMutableDictionary *tasksWithQueryDict;
- (void)saveTasksWithQuery;
@property (nonatomic, readonly) NSMutableDictionary *editedTasksDict;
- (void)saveEditedTasks;

@end
