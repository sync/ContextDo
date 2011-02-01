#import "CacheServices.h"


@implementation CacheServices

SYNTHESIZE_SINGLETON_FOR_CLASS(CacheServices)

@synthesize groupsDict, tasksWithGroupIdDict, editedTasksDict;
@synthesize tasksWithLatitudeDict, tasksWithDueDict, tasksDueTodayDict, groupsOutOfSyncDict;
@synthesize groupOperationsShouldUseSerialQueue;

#pragma mark -
#pragma mark Groups Storage

- (void)addCachedGroup:(Group *)group syncId:(NSNumber *)syncId
{
	Group *previousGroup = (syncId && syncId.integerValue != 0) ? [self groupForSyncId:syncId] : [self groupForId:group.groupId];
	if (!previousGroup) {
		NSMutableArray *cachedGroups = [self.groupsDict valueForKey:@"content"];
		[(NSMutableArray *)cachedGroups insertObject:group atIndex:group.position.integerValue];
		[self saveGroupsDict];
	}
}

- (void)updateCachedGroup:(Group *)group syncId:(NSNumber *)syncId
{
	NSMutableArray *cachedGroups = [self.groupsDict valueForKey:@"content"];
	Group *previousGroup = (syncId && syncId.integerValue != 0) ? [self groupForSyncId:syncId] : [self groupForId:group.groupId];
	if (![previousGroup isEqual:group]) {
		NSInteger idx = [cachedGroups indexOfObject:previousGroup];
		if (idx != NSNotFound) {
			[(NSMutableArray *)cachedGroups replaceObjectAtIndex:idx withObject:group];
		}
	}
	[self saveGroupsDict];
}

- (void)deleteCachedGroup:(Group *)group syncId:(NSNumber *)syncId
{
	Group *previousGroup = (syncId && syncId.integerValue != 0) ? [self groupForSyncId:syncId] : [self groupForId:group.groupId];
	if (previousGroup) {
		NSArray *cachedGroups = [self.groupsDict valueForKey:@"content"];
		NSInteger idx = [cachedGroups indexOfObject:previousGroup];
		if (idx != NSNotFound) {
			[(NSMutableArray *)cachedGroups removeObjectAtIndex:idx];
			[self saveGroupsDict];
		}
	}	
}

- (Group *)groupForId:(NSNumber *)groupId
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupId == %@", groupId];
	NSArray *foundGroups = [[self.groupsDict valueForKey:@"content"] filteredArrayUsingPredicate:predicate];
	
	return (foundGroups.count > 0) ? [foundGroups objectAtIndex:0] : nil;
}

- (NSMutableDictionary *)groupsDict
{
	if (!groupsDict) {
		groupsDict = [[NSDictionary savedDictForKey:GroupsKey]mutableCopy]; 
		if (!groupsDict) {
			groupsDict = [[NSMutableDictionary alloc]init];
		}
	}
	
	return groupsDict;
}

- (void)saveGroupsDict
{
	NSSortDescriptor *order = [[[NSSortDescriptor alloc]initWithKey:@"position" ascending:TRUE]autorelease];
	NSArray *sortDescriptors = [NSArray arrayWithObject:order];
	NSArray *content = [self.groupsDict valueForKey:@"content"];
	[(NSMutableArray *)content sortUsingDescriptors:sortDescriptors];
	[self.groupsDict saveDictForKey:GroupsKey];
	[[NSNotificationCenter defaultCenter]postNotificationName:GroupsDidChangeNotification object:content];
}

#pragma mark -
#pragma mark Tasks Storage

- (NSMutableDictionary *)tasksWithGroupIdDict
{
	if (!tasksWithGroupIdDict) {
		tasksWithGroupIdDict = [[NSDictionary savedDictForKey:TasksWithGroupIdKey]mutableCopy]; 
		if (!tasksWithGroupIdDict) {
			tasksWithGroupIdDict = [[NSMutableDictionary alloc]init];
		}
	}
	
	return tasksWithGroupIdDict;
}

- (void)saveTasksWithGroupId
{
	[self.tasksWithGroupIdDict saveDictForKey:TasksWithGroupIdKey];
}

- (NSMutableDictionary *)tasksWithDueDict
{
	if (!tasksWithDueDict) {
		tasksWithDueDict = [[NSDictionary savedDictForKey:TasksWithDueKey]mutableCopy]; 
		if (!tasksWithDueDict) {
			tasksWithDueDict = [[NSMutableDictionary alloc]init];
		}
	}
	
	return tasksWithDueDict;
}

- (void)saveTasksWithDue
{
	[self.tasksWithDueDict saveDictForKey:TasksWithDueKey];
}

- (NSMutableDictionary *)tasksDueTodayDict
{
	if (!tasksDueTodayDict) {
		tasksDueTodayDict = [[NSDictionary savedDictForKey:TasksDueTodaydKey]mutableCopy]; 
		if (!tasksDueTodayDict) {
			tasksDueTodayDict = [[NSMutableDictionary alloc]init];
		}
	}
	
	return tasksDueTodayDict;
}

- (void)saveTasksDueToday
{
	[self.tasksDueTodayDict saveDictForKey:TasksDueTodaydKey];
}

- (NSMutableDictionary *)tasksWithLatitudeDict
{
	if (!tasksWithLatitudeDict) {
		tasksWithLatitudeDict = [[NSDictionary savedDictForKey:TasksWithLatitudeKey]mutableCopy]; 
		if (!tasksWithLatitudeDict) {
			tasksWithLatitudeDict = [[NSMutableDictionary alloc]init];
		}
	}
	
	return tasksWithLatitudeDict;
}

- (NSArray *)tasksWithin
{
	if ([AppDelegate sharedAppDelegate].hasValidCurrentLocation) {
		NSArray *allKeys = [self.tasksWithLatitudeDict allKeys];
		if (allKeys.count > 0) {
			NSString *savedLatLngString = [allKeys objectAtIndex:0];
			NSArray *coordinatesArray = [savedLatLngString componentsSeparatedByString:@","];
			if (coordinatesArray.count == 2) {
				CLLocation *location = [[[CLLocation alloc]initWithLatitude:[[coordinatesArray objectAtIndex:0]doubleValue]
																  longitude:[[coordinatesArray objectAtIndex:1]doubleValue]]autorelease];
				CGFloat distance = [APIServices sharedAPIServices].alertsDistanceWithin.floatValue * 1000;
				if ([[AppDelegate sharedAppDelegate].currentLocation distanceFromLocation:location] < distance) {
					NSDictionary *savedDict = [self.tasksWithLatitudeDict valueForKey:savedLatLngString];
					return [savedDict valueForKey:@"content"];
				}
			}
		}
	}
	return nil;
}

- (void)saveTasksWithLatitude
{
	[self.tasksWithLatitudeDict saveDictForKey:TasksWithLatitudeKey];
}

- (NSMutableDictionary *)editedTasksDict
{
	if (!editedTasksDict) {
		editedTasksDict = [[NSDictionary savedDictForKey:EditedTasksKey]mutableCopy]; 
		if (!editedTasksDict) {
			editedTasksDict = [[NSMutableDictionary alloc]init];
		}
	}
	
	return editedTasksDict;
}

- (void)saveEditedTasks
{
	[self.editedTasksDict saveDictForKey:EditedTasksKey];
}

#pragma mark -
#pragma mark Syncing

- (BOOL)groupOperationsShouldUseSerialQueue
{
	return ([[self.groupsOutOfSyncDict valueForKey:AddedKey]count] > 0 ||
			[[self.groupsOutOfSyncDict valueForKey:UpdatedKey]count] > 0 ||
			[[self.groupsOutOfSyncDict valueForKey:DeletedKey]count] > 0);
}

#define GroupsOutOfSyncKey @"GroupsOutOfSyncKey"

- (Group *)groupForSyncId:(NSNumber *)syncId
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"syncId == %@", syncId];
	NSArray *foundGroups = [[self.groupsDict valueForKey:@"content"] filteredArrayUsingPredicate:predicate];
	
	return (foundGroups.count > 0) ? [foundGroups objectAtIndex:0] : nil;
}

- (NSMutableDictionary *)groupsOutOfSyncDict
{
	if (!groupsOutOfSyncDict) {
		groupsOutOfSyncDict = [[NSDictionary savedDictForKey:GroupsOutOfSyncKey]mutableCopy]; 
		if (!groupsOutOfSyncDict) {
			groupsOutOfSyncDict = [[NSMutableDictionary alloc]init];
		}
	}
	
	return groupsOutOfSyncDict;
}

- (void)savegroupsOutOfSync
{
	[self.groupsOutOfSyncDict saveDictForKey:GroupsOutOfSyncKey];
}

#pragma mark -
#pragma mark Cache Clearing

- (void)clearCachedData
{
	[self.groupsOutOfSyncDict removeAllObjects];
	[self savegroupsOutOfSync];
	[groupsOutOfSyncDict release];
	groupsOutOfSyncDict = nil;
	[self.tasksWithGroupIdDict removeAllObjects];
	[self saveTasksWithGroupId];
	[tasksWithGroupIdDict release];
	tasksWithGroupIdDict = nil;
	[self.tasksWithDueDict removeAllObjects];
	[self saveTasksWithDue];
	[tasksWithDueDict release];
	tasksWithDueDict = nil;
	[self.tasksDueTodayDict removeAllObjects];
	[self saveTasksDueToday];
	[tasksDueTodayDict release];
	tasksDueTodayDict = nil;
	[self.tasksWithLatitudeDict removeAllObjects];
	[self saveTasksWithLatitude];
	[tasksWithLatitudeDict release];
	tasksWithLatitudeDict = nil;
	[self.editedTasksDict removeAllObjects];
	[self saveEditedTasks];
	[editedTasksDict release];
	editedTasksDict = nil;
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[groupsOutOfSyncDict release];
	[editedTasksDict release];
	[tasksWithLatitudeDict release];
	[tasksWithDueDict release];
	[tasksDueTodayDict release];
	[tasksWithGroupIdDict release];
	[groupsDict release];
	
	[super dealloc];
}

@end
