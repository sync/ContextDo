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

- (BOOL)hasCachedGroup:(Group *)group syncId:(NSNumber *)syncId;
- (void)addCachedGroup:(Group *)group syncId:(NSNumber *)syncId;
- (void)updateCachedGroup:(Group *)group syncId:(NSNumber *)syncId;
- (void)deleteCachedGroup:(Group *)group syncId:(NSNumber *)syncId;
- (Group *)cachedGroupForId:(NSNumber *)groupId;
- (Group *)cachedGroupForSyncId:(NSNumber *)syncId;
@property (nonatomic, readonly) NSMutableDictionary *groupsDict;
- (void)saveGroups;

- (BOOL)hasCachedTask:(Task *)task syncId:(NSNumber *)syncId;
- (void)addCachedTask:(Task *)task syncId:(NSNumber *)syncId;
- (void)updateCachedTask:(Task *)task syncId:(NSNumber *)syncId;
- (void)deleteCachedTask:(Task *)task syncId:(NSNumber *)syncId;

- (void)addCachedTask:(Task *)task forGroupId:(NSNumber *)groupId syncId:(NSNumber *)syncId;
- (void)updateCachedTask:(Task *)task forGroupId:(NSNumber *)groupId syncId:(NSNumber *)syncId;
- (void)deleteCachedTask:(Task *)task forGroupId:(NSNumber *)groupId syncId:(NSNumber *)syncId;
- (Task *)cachedTaskForGroupId:(NSNumber *)groupId taskId:(NSNumber *)taskId;
- (Task *)cachedTaskForGroupId:(NSNumber *)groupId syncId:(NSNumber *)syncId;
@property (nonatomic, readonly) NSMutableDictionary *tasksWithGroupIdDict;
- (void)saveTasksWithGroupId;

- (void)addCachedTask:(Task *)task forDueAt:(NSDate *)dueAt syncId:(NSNumber *)syncId;
- (void)updateCachedTask:(Task *)task forDueAt:(NSDate *)dueAt syncId:(NSNumber *)syncId;
- (void)deleteCachedTask:(Task *)task forDueAt:(NSDate *)dueAt syncId:(NSNumber *)syncId;
- (Task *)cachedTaskForDueAt:(NSDate *)dueAt taskId:(NSNumber *)taskId;
- (Task *)cachedTaskForDueAt:(NSDate *)dueAt syncId:(NSNumber *)syncId;
@property (nonatomic, readonly) NSMutableDictionary *tasksWithDueDict;
- (void)saveTasksWithDue;

- (void)addCachedTask:(Task *)task forTodayDueAt:(NSDate *)dueAt syncId:(NSNumber *)syncId;
- (void)updateCachedTask:(Task *)task forTodayDueAt:(NSDate *)dueAt syncId:(NSNumber *)syncId;
- (void)deleteCachedTask:(Task *)task forTodayDueAt:(NSDate *)dueAt syncId:(NSNumber *)syncId;
- (Task *)cachedTaskForTodayDueAt:(NSDate *)dueAt taskId:(NSNumber *)taskId;
- (Task *)cachedTaskForTodayDueAt:(NSDate *)dueAt syncId:(NSNumber *)syncId;
@property (nonatomic, readonly) NSMutableDictionary *tasksDueTodayDict;
- (void)saveTasksDueToday;

- (void)addCachedTask:(Task *)task forLatLngString:(NSString *)latLngString syncId:(NSNumber *)syncId;
- (void)updateCachedTask:(Task *)task forLatLngString:(NSString *)latLngString syncId:(NSNumber *)syncId;
- (void)deleteCachedTask:(Task *)task forLatLngString:(NSString *)latLngString syncId:(NSNumber *)syncId;
- (Task *)cachedTaskForLatLngString:(NSString *)latLngString taskId:(NSNumber *)taskId;
- (Task *)cachedTaskForLatLngString:(NSString *)latLngString syncId:(NSNumber *)syncId;
@property (nonatomic, readonly) NSMutableDictionary *tasksWithLatitudeDict;
@property (nonatomic, readonly) NSArray *tasksWithin;
- (void)saveTasksWithLatitude;

- (void)addCachedTask:(Task *)task forUpdatedAt:(NSDate *)updatedAt syncId:(NSNumber *)syncId;
- (void)updateCachedTask:(Task *)task forUpdatedAt:(NSDate *)updatedAt syncId:(NSNumber *)syncId;
- (void)deleteCachedTask:(Task *)task forUpdatedAt:(NSDate *)updatedAt syncId:(NSNumber *)syncId;
- (Task *)cachedTaskForUpdatedAt:(NSDate *)updatedAt taskId:(NSNumber *)taskId;
- (Task *)cachedTaskForUpdatedAt:(NSDate *)updatedAt syncId:(NSNumber *)syncId;
@property (nonatomic, readonly) NSMutableDictionary *editedTasksDict;
- (void)saveEditedTasks;

@property (nonatomic) BOOL groupOperationsShouldUseSerialQueue;
@property (nonatomic, readonly) NSMutableDictionary *groupsOutOfSyncDict;
- (void)saveGroupsOutOfSync;

@property (nonatomic) BOOL taskOperationsShouldUseSerialQueue;
@property (nonatomic, readonly) NSMutableDictionary *tasksOutOfSyncDict;
- (void)saveTasksOutOfSync;

- (void)clearCachedData;

@end
