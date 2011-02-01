#import <Foundation/Foundation.h>
#import "BaseASIServices.h"
#import "NSDictionary+Persistence.h"

#define AddedKey @"added"
#define UpdatedKey @"updated"
#define DeletedKey @"deleted"

@interface APIServices : BaseASIServices {

}

+ (APIServices *)sharedAPIServices;

@property (nonatomic, retain) ASINetworkQueue *serialNetworkQueue;
@property (nonatomic) BOOL groupOperationsUserSerialQueue;
- (void)downloadSeriallyContentForUrl:(NSString *)url withObject:(id)object path:(NSString *)path notificationName:(NSString *)notificationName;

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

@property (nonatomic, assign) User *user;
- (void)refreshUser;
- (void)updateUser:(User *)user;
@property (nonatomic, assign) NSNumber *alertsDistanceWithin;
- (CGFloat)alertsDistancKmToSliderValue:(CGFloat)value;
- (CGFloat)sliderValueToAlertsDistancKm:(CGFloat)value;

- (Group *)groupForId:(NSNumber *)groupId;
@property (nonatomic, readonly) NSMutableDictionary *groupsDict;
- (void)saveGroupsDict;
@property (nonatomic, readonly) NSMutableDictionary *tasksWithGroupIdDict;
- (void)saveTasksWithGroupId;
@property (nonatomic, readonly) NSMutableDictionary *tasksDueTodayDict;
- (void)saveTasksDueToday;
@property (nonatomic, readonly) NSMutableDictionary *tasksWithDueDict;
- (void)saveTasksWithDue;
@property (nonatomic, readonly) NSMutableDictionary *tasksWithLatitudeDict;
@property (nonatomic, readonly) NSArray *tasksWithin;
- (void)saveTasksWithLatitude;
@property (nonatomic, readonly) NSMutableDictionary *editedTasksDict;
- (void)saveEditedTasks;

- (Group *)groupForSyncId:(NSNumber *)syncId;
@property (nonatomic, readonly) NSMutableDictionary *groupsOutOfSyncDict;

- (void)clearPersistedData;



@end
