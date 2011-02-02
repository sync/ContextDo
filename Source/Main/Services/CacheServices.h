#import <Foundation/Foundation.h>
#import "NSDictionary+Persistence.h"

#define AddedKey @"added"
#define UpdatedKey @"updated"
#define DeletedKey @"deleted"

#define GroupsKey @"groups"
#define TasksWithGroupIdKey @"tasksWithGroupId"
#define TasksWithDueKey @"tasksWithDue"
#define TasksDueTodaydKey @"tasksDueToday"
#define TasksWithLatitudeKey @"tasksWithLatitude"
#define TasksWithQueryKey @"tasksWithQuery"
#define EditedTasksKey @"editedTasks"

@interface CacheServices : NSObject {

}

+ (CacheServices *)sharedCacheServices;

- (void)addCachedGroup:(Group *)group syncId:(NSNumber *)syncId;
- (void)updateCachedGroup:(Group *)group syncId:(NSNumber *)syncId;
- (void)deleteCachedGroup:(Group *)group syncId:(NSNumber *)syncId;
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

@property (nonatomic) BOOL groupOperationsShouldUseSerialQueue;
- (Group *)groupForSyncId:(NSNumber *)syncId;
@property (nonatomic, readonly) NSMutableDictionary *groupsOutOfSyncDict;
- (void)saveGroupsOutOfSync;

@property (nonatomic) BOOL taskOperationsShouldUseSerialQueue;
- (Task *)taskForSyncId:(NSNumber *)syncId;
@property (nonatomic, readonly) NSMutableDictionary *tasksOutOfSyncDict;
- (void)saveTasksOutOfSync;

- (void)clearCachedData;

@end
