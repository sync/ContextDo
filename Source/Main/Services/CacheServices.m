#import "CacheServices.h"
#import "NSDate+Extensions.h"
#import "NSDate-Utilities.h"

@implementation CacheServices

SYNTHESIZE_SINGLETON_FOR_CLASS(CacheServices)

@synthesize groupsDict, tasksWithGroupIdDict, editedTasksDict;
@synthesize tasksWithLatitudeDict, tasksWithDueDict, tasksDueTodayDict, groupsOutOfSyncDict;
@synthesize groupOperationsShouldUseSerialQueue, tasksOutOfSyncDict, taskOperationsShouldUseSerialQueue;

#pragma mark -
#pragma mark Groups Storage

- (BOOL)hasCachedGroup:(Group *)group syncId:(NSNumber *)syncId
{
	Group *previousGroup = (syncId && syncId.integerValue != 0) ? [self cachedGroupForSyncId:syncId] : [self cachedGroupForId:group.groupId];
	return (previousGroup != nil);
}

- (void)addCachedGroup:(Group *)group syncId:(NSNumber *)syncId
{
	if (!group) {
		return;
	}
	
	Group *previousGroup = (syncId && syncId.integerValue != 0) ? [self cachedGroupForSyncId:syncId] : [self cachedGroupForId:group.groupId];
	if (!previousGroup) {
		NSArray *content = [self.groupsDict valueForKey:@"content"];
		if (!content) {
			[[CacheServices sharedCacheServices].groupsDict setValue:[NSArray arrayWithObject:group] forKey:@"content"];
		} else {
			[(NSMutableArray *)content insertObject:group atIndex:group.position.integerValue];
		}
		[self saveGroups];
	}
}

- (void)updateCachedGroup:(Group *)group syncId:(NSNumber *)syncId
{
	if (!group) {
		return;
	}
	
	NSMutableArray *cachedGroups = [self.groupsDict valueForKey:@"content"];
	Group *previousGroup = (syncId && syncId.integerValue != 0) ? [self cachedGroupForSyncId:syncId] : [self cachedGroupForId:group.groupId];
	NSInteger idx = [cachedGroups indexOfObject:previousGroup];
	if (idx != NSNotFound) {
		[(NSMutableArray *)cachedGroups replaceObjectAtIndex:idx withObject:group];
		[self saveGroups];
	}
}

- (void)deleteCachedGroup:(Group *)group syncId:(NSNumber *)syncId
{
	if (!group) {
		return;
	}
	
	Group *previousGroup = (syncId && syncId.integerValue != 0) ? [self cachedGroupForSyncId:syncId] : [self cachedGroupForId:group.groupId];
	if (previousGroup) {
		NSArray *cachedGroups = [self.groupsDict valueForKey:@"content"];
		NSInteger idx = [cachedGroups indexOfObject:previousGroup];
		if (idx != NSNotFound) {
			[(NSMutableArray *)cachedGroups removeObjectAtIndex:idx];
			[self saveGroups];
		}
	}	
}

- (Group *)cachedGroupForId:(NSNumber *)groupId
{
	if (!groupId) {
		return nil;
	}
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupId == %@", groupId];
	NSArray *foundGroups = [[self.groupsDict valueForKey:@"content"] filteredArrayUsingPredicate:predicate];
	
	return (foundGroups.count > 0) ? [foundGroups objectAtIndex:0] : nil;
}

- (Group *)cachedGroupForSyncId:(NSNumber *)syncId
{
	if (!syncId) {
		return nil;
	}
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"syncId == %@", syncId];
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

- (void)saveGroups
{
	NSSortDescriptor *order = [[[NSSortDescriptor alloc]initWithKey:@"position" ascending:TRUE]autorelease];
	NSArray *sortDescriptors = [NSArray arrayWithObject:order];
	NSArray *content = [self.groupsDict valueForKey:@"content"];
	[(NSMutableArray *)content sortUsingDescriptors:sortDescriptors];
	[self.groupsDict saveDictForKey:GroupsKey];
	[[NSNotificationCenter defaultCenter]postNotificationName:GroupsGraphDidLoadNotification object:self.groupsDict];
}

#pragma mark -
#pragma mark Tasks Storage

- (BOOL)hasCachedTask:(Task *)task syncId:(NSNumber *)syncId
{
	Task *previousTask1 = (syncId && syncId.integerValue != 0) ? [self cachedTaskForGroupId:task.groupId taskId:task.taskId] : [self cachedTaskForGroupId:task.groupId syncId:task.syncId];
	Task *previousTask2 = (syncId && syncId.integerValue != 0) ? [self cachedTaskForDueAt:task.dueAt taskId:task.taskId] : [self cachedTaskForDueAt:task.dueAt syncId:task.syncId];
	Task *previousTask3 = (syncId && syncId.integerValue != 0) ? [self cachedTaskForDueAt:task.dueAt taskId:task.taskId] : [self cachedTaskForDueAt:task.dueAt syncId:task.syncId];
	Task *previousTask4 = (syncId && syncId.integerValue != 0) ? [self cachedTaskForLatLngString:task.latLngString taskId:task.taskId] : [self cachedTaskForLatLngString:task.latLngString syncId:task.syncId];
	Task *previousTask5 = (syncId && syncId.integerValue != 0) ? [self cachedTaskForUpdatedAt:task.updatedAt taskId:task.taskId] : [self cachedTaskForUpdatedAt:task.updatedAt syncId:task.syncId];
	
	return (previousTask1 || previousTask2 || previousTask3 || previousTask4 || previousTask5);
}

- (void)addCachedTask:(Task *)task syncId:(NSNumber *)syncId
{
	if (!task) {
		return;
	}
	
	[self addCachedTask:task forGroupId:task.groupId syncId:syncId];
	[self addCachedTask:task forTodayDueAt:task.dueAt syncId:syncId];
	[self addCachedTask:task forDueAt:task.dueAt syncId:syncId];
	if (task.completed) {
		[self addCachedTask:task forTodayDueAt:[task.dueAt dateByAddingDays:1] syncId:syncId];
		[self addCachedTask:task forDueAt:[task.dueAt dateByAddingDays:1] syncId:syncId];
	}
	[self addCachedTask:task forLatLngString:task.latLngString syncId:syncId];
	[self addCachedTask:task forUpdatedAt:task.updatedAt syncId:syncId];
}

- (void)updateCachedTask:(Task *)task syncId:(NSNumber *)syncId
{
	if (!task) {
		return;
	}
	
	[self deleteCachedTask:task syncId:syncId];
	[self addCachedTask:task syncId:syncId];
}

- (void)deleteCachedTask:(Task *)task syncId:(NSNumber *)syncId
{
	if (!task) {
		return;
	}
	
	[self deleteCachedTask:task forGroupId:task.groupId syncId:syncId];
	[self deleteCachedTask:task forTodayDueAt:task.dueAt syncId:syncId];
	[self deleteCachedTask:task forTodayDueAt:[task.dueAt dateByAddingDays:1] syncId:syncId];
	[self deleteCachedTask:task forDueAt:task.dueAt syncId:syncId];
	[self deleteCachedTask:task forDueAt:[task.dueAt dateByAddingDays:1] syncId:syncId];
	[self deleteCachedTask:task forLatLngString:task.latLngString syncId:syncId];
	[self deleteCachedTask:task forUpdatedAt:task.updatedAt syncId:syncId];
}

#pragma mark -- by Group

- (void)addCachedTask:(Task *)task forGroupId:(NSNumber *)groupId syncId:(NSNumber *)syncId
{
	if (!task && (groupId || syncId)) {
		return;
	}
	
	Task *previousTask = (syncId && syncId.integerValue != 0) ? [self cachedTaskForGroupId:groupId taskId:task.taskId] : [self cachedTaskForGroupId:groupId syncId:task.syncId];
	if (!previousTask) {
		NSString *key = [groupId stringValue];
		NSDictionary *dictionary = [self.tasksWithGroupIdDict valueForKey:key];
		if (!dictionary) {
			NSDictionary *dict = [NSDictionary dictionaryWithContent:[NSMutableArray arrayWithObject:task] date:[NSDate date]];
			[self.tasksWithGroupIdDict setValue:dict forKey:key];
		} else {
			NSMutableArray *content = [dictionary valueForKey:@"content"];
			if (content) {
				[content addObject:task];
			}
		}
		[self saveTasksWithGroupId];
	}
}

- (void)updateCachedTask:(Task *)task forGroupId:(NSNumber *)groupId syncId:(NSNumber *)syncId
{
	if (!task && (groupId || syncId)) {
		return;
	}
	
	Task *previousTask = (syncId && syncId.integerValue != 0) ? [self cachedTaskForGroupId:groupId taskId:task.taskId] : [self cachedTaskForGroupId:groupId syncId:task.syncId];
	if (![previousTask isEqual:task]) {
		NSString *key = [groupId stringValue];
		NSDictionary *dictionary = [self.tasksWithGroupIdDict valueForKey:key];
		if (dictionary) {
			NSMutableArray *content = [dictionary valueForKey:@"content"];
			NSInteger idx = [content indexOfObject:previousTask];
			if (idx != NSNotFound) {
				[content replaceObjectAtIndex:idx withObject:task];
				[self saveTasksWithGroupId];
			}
		}
	}
}

- (void)deleteCachedTask:(Task *)task forGroupId:(NSNumber *)groupId syncId:(NSNumber *)syncId
{
	if (!task && (groupId || syncId)) {
		return;
	}
	
	Task *previousTask = (syncId && syncId.integerValue != 0) ? [self cachedTaskForGroupId:groupId taskId:task.taskId] : [self cachedTaskForGroupId:groupId syncId:task.syncId];
	if (previousTask) {
		NSString *key = [groupId stringValue];
		NSDictionary *dictionary = [self.tasksWithGroupIdDict valueForKey:key];
		if (dictionary) {
			NSMutableArray *content = [dictionary valueForKey:@"content"];
			[content removeObject:previousTask];
			[self saveTasksWithGroupId];
		}
	}
}

- (Task *)cachedTaskForGroupId:(NSNumber *)groupId taskId:(NSNumber *)taskId
{
	if (!groupId || !taskId) {
		return nil;
	}
	
	NSString *key = [groupId stringValue];
	NSDictionary *dictionary = [self.tasksWithGroupIdDict valueForKey:key];
	if (!dictionary) {
		return nil;
	}
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taskId == %@", taskId];
	NSArray *foundTasks = [[dictionary valueForKey:@"content"] filteredArrayUsingPredicate:predicate];
	
	return (foundTasks.count > 0) ? [foundTasks objectAtIndex:0] : nil;
}

- (Task *)cachedTaskForGroupId:(NSNumber *)groupId syncId:(NSNumber *)syncId
{
	if (!groupId || !syncId) {
		return nil;
	}
	
	NSString *key = [groupId stringValue];
	NSDictionary *dictionary = [self.tasksWithGroupIdDict valueForKey:key];
	if (!dictionary) {
		return nil;
	}
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"syncId == %@", syncId];
	NSArray *foundTasks = [[dictionary valueForKey:@"content"] filteredArrayUsingPredicate:predicate];
	
	return (foundTasks.count > 0) ? [foundTasks objectAtIndex:0] : nil;
}

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
	[[NSNotificationCenter defaultCenter]postNotificationName:TasksGraphDidLoadNotification 
													   object:self.tasksWithGroupIdDict];
}

#pragma mark -- by Due

- (void)addCachedTask:(Task *)task forDueAt:(NSDate *)dueAt syncId:(NSNumber *)syncId
{
	if (!task || !dueAt) {
		return;
	}
	
	Task *previousTask = (syncId && syncId.integerValue != 0) ? [self cachedTaskForDueAt:dueAt taskId:task.taskId] : [self cachedTaskForDueAt:dueAt syncId:task.syncId];
	if (!previousTask) {
		NSString *key = [dueAt getUTCDateWithformat:@"yyyy-MM-dd"];
		NSDictionary *dictionary = [self.tasksWithDueDict valueForKey:key];
		if (!dictionary) {
			NSDictionary *dict = [NSDictionary dictionaryWithContent:[NSMutableArray arrayWithObject:task] date:[NSDate date]];
			[self.tasksWithDueDict setValue:dict forKey:key];
		} else {
			NSMutableArray *content = [dictionary valueForKey:@"content"];
			if (content) {
				[content addObject:task];
			}
		}
		[self saveTasksWithDue];
	}
}

- (void)updateCachedTask:(Task *)task forDueAt:(NSDate *)dueAt syncId:(NSNumber *)syncId
{
	if (!task || !dueAt) {
		return;
	}
	
	Task *previousTask = (syncId && syncId.integerValue != 0) ? [self cachedTaskForDueAt:dueAt taskId:task.taskId] : [self cachedTaskForDueAt:dueAt syncId:task.syncId];
	if (![previousTask isEqual:task]) {
		NSString *key = [dueAt getUTCDateWithformat:@"yyyy-MM-dd"];
		NSDictionary *dictionary = [self.tasksWithDueDict valueForKey:key];
		if (dictionary) {
			NSMutableArray *content = [dictionary valueForKey:@"content"];
			NSInteger idx = [content indexOfObject:previousTask];
			if (idx != NSNotFound) {
				[content replaceObjectAtIndex:idx withObject:task];
				[self saveTasksWithDue];
			}
		}
	}
}

- (void)deleteCachedTask:(Task *)task forDueAt:(NSDate *)dueAt syncId:(NSNumber *)syncId
{
	if (!task || !dueAt) {
		return;
	}
	
	Task *previousTask = (syncId && syncId.integerValue != 0) ? [self cachedTaskForDueAt:dueAt taskId:task.taskId] : [self cachedTaskForDueAt:dueAt syncId:task.syncId];
	if (previousTask) {
		NSString *key = [dueAt getUTCDateWithformat:@"yyyy-MM-dd"];
		NSDictionary *dictionary = [self.tasksWithDueDict valueForKey:key];
		if (dictionary) {
			NSMutableArray *content = [dictionary valueForKey:@"content"];
			[content removeObject:previousTask];
			[self saveTasksWithDue];
		}
	}
}

- (Task *)cachedTaskForDueAt:(NSDate *)dueAt taskId:(NSNumber *)taskId
{
	if (!dueAt || !taskId) {
		return nil;
	}
	
	NSString *key = [dueAt getUTCDateWithformat:@"yyyy-MM-dd"];
	NSDictionary *dictionary = [self.tasksWithDueDict valueForKey:key];
	if (!dictionary) {
		return nil;
	}
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taskId == %@", taskId];
	NSArray *foundTasks = [[dictionary valueForKey:@"content"] filteredArrayUsingPredicate:predicate];
	
	return (foundTasks.count > 0) ? [foundTasks objectAtIndex:0] : nil;
}

- (Task *)cachedTaskForDueAt:(NSDate *)dueAt syncId:(NSNumber *)syncId
{
	if (!dueAt || !syncId) {
		return nil;
	}
	
	NSString *key = [dueAt getUTCDateWithformat:@"yyyy-MM-dd"];
	NSDictionary *dictionary = [self.tasksWithDueDict valueForKey:key];
	if (!dictionary) {
		return nil;
	}
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"syncId == %@", syncId];
	NSArray *foundTasks = [[dictionary valueForKey:@"content"] filteredArrayUsingPredicate:predicate];
	
	return (foundTasks.count > 0) ? [foundTasks objectAtIndex:0] : nil;
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
	[[NSNotificationCenter defaultCenter]postNotificationName:TasksGraphDueDidLoadNotification 
													   object:[self.tasksWithDueDict valueForKey:@"content"]];
}

#pragma mark -- Today

- (void)addCachedTask:(Task *)task forTodayDueAt:(NSDate *)dueAt syncId:(NSNumber *)syncId
{
	if (!task || !dueAt) {
		return;
	}
	
	Task *previousTask = (syncId && syncId.integerValue != 0) ? [self cachedTaskForDueAt:dueAt taskId:task.taskId] : [self cachedTaskForDueAt:dueAt syncId:task.syncId];
	if (!previousTask) {
		NSString *key = [dueAt getUTCDateWithformat:@"yyyy-MM-dd"];
		NSDictionary *dictionary = [self.tasksDueTodayDict valueForKey:key];
		if (!dictionary) {
			NSDictionary *dict = [NSDictionary dictionaryWithContent:[NSMutableArray arrayWithObject:task] date:[NSDate date]];
			[self.tasksDueTodayDict setValue:dict forKey:key];
		} else {
			NSMutableArray *content = [dictionary valueForKey:@"content"];
			if (content) {
				[content addObject:task];
			}
		}
		[self saveTasksDueToday];
	}
}

- (void)updateCachedTask:(Task *)task forTodayDueAt:(NSDate *)dueAt syncId:(NSNumber *)syncId
{
	if (!task || !dueAt) {
		return;
	}
	
	Task *previousTask = (syncId && syncId.integerValue != 0) ? [self cachedTaskForDueAt:dueAt taskId:task.taskId] : [self cachedTaskForDueAt:dueAt syncId:task.syncId];
	if (![previousTask isEqual:task]) {
		NSString *key = [dueAt getUTCDateWithformat:@"yyyy-MM-dd"];
		NSDictionary *dictionary = [self.tasksDueTodayDict valueForKey:key];
		if (dictionary) {
			NSMutableArray *content = [dictionary valueForKey:@"content"];
			NSInteger idx = [content indexOfObject:previousTask];
			if (idx != NSNotFound) {
				[content replaceObjectAtIndex:idx withObject:task];
				[self saveTasksDueToday];
			}
		}
	}
}

- (void)deleteCachedTask:(Task *)task forTodayDueAt:(NSDate *)dueAt syncId:(NSNumber *)syncId
{
	if (!task || !dueAt) {
		return;
	}
	
	Task *previousTask = (syncId && syncId.integerValue != 0) ? [self cachedTaskForDueAt:dueAt taskId:task.taskId] : [self cachedTaskForDueAt:dueAt syncId:task.syncId];
	if (previousTask) {
		NSString *key = [dueAt getUTCDateWithformat:@"yyyy-MM-dd"];
		NSDictionary *dictionary = [self.tasksDueTodayDict valueForKey:key];
		if (dictionary) {
			NSMutableArray *content = [dictionary valueForKey:@"content"];
			[content removeObject:previousTask];
			[self saveTasksDueToday];
		}
	}
}

- (Task *)cachedTaskForTodayDueAt:(NSDate *)dueAt taskId:(NSNumber *)taskId
{
	if (!dueAt || !taskId) {
		return nil;
	}
	
	NSString *key = [dueAt getUTCDateWithformat:@"yyyy-MM-dd"];
	NSDictionary *dictionary = [self.tasksDueTodayDict valueForKey:key];
	if (!dictionary) {
		return nil;
	}
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taskId == %@", taskId];
	NSArray *foundTasks = [[dictionary valueForKey:@"content"] filteredArrayUsingPredicate:predicate];
	
	return (foundTasks.count > 0) ? [foundTasks objectAtIndex:0] : nil;
}

- (Task *)cachedTaskForTodayDueAt:(NSDate *)dueAt syncId:(NSNumber *)syncId
{
	if (!dueAt || !syncId) {
		return nil;
	}
	
	NSString *key = [dueAt getUTCDateWithformat:@"yyyy-MM-dd"];
	NSDictionary *dictionary = [self.tasksDueTodayDict valueForKey:key];
	if (!dictionary) {
		return nil;
	}
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"syncId == %@", syncId];
	NSArray *foundTasks = [[dictionary valueForKey:@"content"] filteredArrayUsingPredicate:predicate];
	
	return (foundTasks.count > 0) ? [foundTasks objectAtIndex:0] : nil;
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
	[[NSNotificationCenter defaultCenter]postNotificationName:TasksGraphDueTodayDidLoadNotification 
													   object:[self.tasksDueTodayDict valueForKey:@"content"]];
}

#pragma mark -- by Lat/Lng

- (void)addCachedTask:(Task *)task forLatLngString:(NSString *)latLngString syncId:(NSNumber *)syncId
{
	if (!task || !latLngString) {
		return;
	}
	
	Task *previousTask = (syncId && syncId.integerValue != 0) ? [self cachedTaskForLatLngString:latLngString taskId:task.taskId] : [self cachedTaskForLatLngString:latLngString syncId:task.syncId];
	if (!previousTask) {
		NSString *key = latLngString;
		NSDictionary *dictionary = [self.tasksWithLatitudeDict valueForKey:key];
		if (dictionary) {
			NSMutableArray *content = [dictionary valueForKey:@"content"];
			if (content) {
				[content addObject:task];
			}
		}
		[self saveTasksWithLatitude];
	}
}

- (void)updateCachedTask:(Task *)task forLatLngString:(NSString *)latLngString syncId:(NSNumber *)syncId
{
	if (!task || !latLngString) {
		return;
	}
	
	Task *previousTask = (syncId && syncId.integerValue != 0) ? [self cachedTaskForLatLngString:latLngString taskId:task.taskId] : [self cachedTaskForLatLngString:latLngString syncId:task.syncId];
	if (![previousTask isEqual:task]) {
		NSString *key = latLngString;
		NSDictionary *dictionary = [self.tasksWithLatitudeDict valueForKey:key];
		if (dictionary) {
			NSMutableArray *content = [dictionary valueForKey:@"content"];
			NSInteger idx = [content indexOfObject:previousTask];
			if (idx != NSNotFound) {
				[content replaceObjectAtIndex:idx withObject:task];
				[self saveTasksWithLatitude];
			}
		}
	}
}

- (void)deleteCachedTask:(Task *)task forLatLngString:(NSString *)latLngString syncId:(NSNumber *)syncId
{
	if (!task || !latLngString) {
		return;
	}
	
	Task *previousTask = (syncId && syncId.integerValue != 0) ? [self cachedTaskForLatLngString:latLngString taskId:task.taskId] : [self cachedTaskForLatLngString:latLngString syncId:task.syncId];
	if (previousTask) {
		NSString *key = latLngString;
		NSDictionary *dictionary = [self.tasksWithLatitudeDict valueForKey:key];
		if (dictionary) {
			NSMutableArray *content = [dictionary valueForKey:@"content"];
			[content removeObject:previousTask];
			[self saveTasksWithLatitude];
		}
	}
}

- (Task *)cachedTaskForLatLngString:(NSString *)latLngString taskId:(NSNumber *)taskId
{
	if (!latLngString || !taskId) {
		return nil;
	}
	
	NSString *key = latLngString;
	NSDictionary *dictionary = [self.tasksWithLatitudeDict valueForKey:key];
	if (!dictionary) {
		return nil;
	}
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taskId == %@", taskId];
	NSArray *foundTasks = [[dictionary valueForKey:@"content"] filteredArrayUsingPredicate:predicate];
	
	return (foundTasks.count > 0) ? [foundTasks objectAtIndex:0] : nil;
}

- (Task *)cachedTaskForLatLngString:(NSString *)latLngString syncId:(NSNumber *)syncId
{
	if (!latLngString || !syncId) {
		return nil;
	}
	
	NSString *key = latLngString;
	NSDictionary *dictionary = [self.tasksWithLatitudeDict valueForKey:key];
	if (!dictionary) {
		return nil;
	}
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"syncId == %@", syncId];
	NSArray *foundTasks = [[dictionary valueForKey:@"content"] filteredArrayUsingPredicate:predicate];
	
	return (foundTasks.count > 0) ? [foundTasks objectAtIndex:0] : nil;
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
		NSMutableSet *tasksWithin = [NSMutableSet set];
		for (NSString *latLngString in self.tasksWithLatitudeDict.allKeys) {
			NSArray *coordinatesArray = [latLngString componentsSeparatedByString:@","];
			if (coordinatesArray.count == 2) {
				CLLocation *location = [[[CLLocation alloc]initWithLatitude:[[coordinatesArray objectAtIndex:0]doubleValue]
																  longitude:[[coordinatesArray objectAtIndex:1]doubleValue]]autorelease];
				CGFloat distance = [APIServices sharedAPIServices].alertsDistanceWithin.floatValue * 1000;
				if ([[AppDelegate sharedAppDelegate].currentLocation distanceFromLocation:location] < distance) {
					NSDictionary *savedDict = [self.tasksWithLatitudeDict valueForKey:latLngString];
					[tasksWithin addObjectsFromArray:[savedDict valueForKey:@"content"]];
				}
			}
		}
		// todo hash could be different but might the the same id task
		return tasksWithin.allObjects;
	}
	return nil;
}

- (void)saveTasksWithLatitude
{
	[self.tasksWithLatitudeDict saveDictForKey:TasksWithLatitudeKey];
	[[NSNotificationCenter defaultCenter]postNotificationName:TasksGraphWithinDidLoadNotification 
													   object:[self.tasksWithLatitudeDict valueForKey:@"content"]];
}

#pragma mark -- Edited Today

- (void)addCachedTask:(Task *)task forUpdatedAt:(NSDate *)updatedAt syncId:(NSNumber *)syncId
{
	if (!task || !updatedAt) {
		return;
	}
	
	Task *previousTask = (syncId && syncId.integerValue != 0) ? [self cachedTaskForUpdatedAt:updatedAt taskId:task.taskId] : [self cachedTaskForUpdatedAt:updatedAt syncId:task.syncId];
	if (!previousTask) {
		NSString *key = [updatedAt getUTCDateWithformat:@"yyyy-MM-dd"];
		NSDictionary *dictionary = [self.editedTasksDict valueForKey:key];
		if (!dictionary) {
			NSDictionary *dict = [NSDictionary dictionaryWithContent:[NSMutableArray arrayWithObject:task] date:[NSDate date]];
			[self.editedTasksDict setValue:dict forKey:key];
		} else {
			NSMutableArray *content = [dictionary valueForKey:@"content"];
			if (content) {
				[content addObject:task];
			}
		}
		[self saveEditedTasks];
	}
}

- (void)updateCachedTask:(Task *)task forUpdatedAt:(NSDate *)updatedAt syncId:(NSNumber *)syncId
{
	if (!task || !updatedAt) {
		return;
	}
	
	Task *previousTask = (syncId && syncId.integerValue != 0) ? [self cachedTaskForUpdatedAt:updatedAt taskId:task.taskId] : [self cachedTaskForUpdatedAt:updatedAt syncId:task.syncId];
	if (![previousTask isEqual:task]) {
		NSString *key = [updatedAt getUTCDateWithformat:@"yyyy-MM-dd"];
		NSDictionary *dictionary = [self.editedTasksDict valueForKey:key];
		if (dictionary) {
			NSMutableArray *content = [dictionary valueForKey:@"content"];
			NSInteger idx = [content indexOfObject:previousTask];
			if (idx != NSNotFound) {
				[content replaceObjectAtIndex:idx withObject:task];
				[self saveEditedTasks];
			}
		}
	}
}

- (void)deleteCachedTask:(Task *)task forUpdatedAt:(NSDate *)updatedAt syncId:(NSNumber *)syncId
{
	if (!task || !updatedAt) {
		return;
	}
	
	Task *previousTask = (syncId && syncId.integerValue != 0) ? [self cachedTaskForUpdatedAt:updatedAt taskId:task.taskId] : [self cachedTaskForUpdatedAt:updatedAt syncId:task.syncId];
	if (previousTask) {
		NSString *key = [updatedAt getUTCDateWithformat:@"yyyy-MM-dd"];
		NSDictionary *dictionary = [self.editedTasksDict valueForKey:key];
		if (dictionary) {
			NSMutableArray *content = [dictionary valueForKey:@"content"];
			[content removeObject:previousTask];
			[self saveEditedTasks];
		}
	}
}

- (Task *)cachedTaskForUpdatedAt:(NSDate *)updatedAt taskId:(NSNumber *)taskId
{
	if (!updatedAt || !taskId) {
		return nil;
	}
	
	NSString *key = [updatedAt getUTCDateWithformat:@"yyyy-MM-dd"];
	NSDictionary *dictionary = [self.editedTasksDict valueForKey:key];
	if (!dictionary) {
		return nil;
	}
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taskId == %@", taskId];
	NSArray *foundTasks = [[dictionary valueForKey:@"content"] filteredArrayUsingPredicate:predicate];
	
	return (foundTasks.count > 0) ? [foundTasks objectAtIndex:0] : nil;
}

- (Task *)cachedTaskForUpdatedAt:(NSDate *)updatedAt syncId:(NSNumber *)syncId
{
	if (!updatedAt || !syncId) {
		return nil;
	}
	
	NSString *key = [updatedAt getUTCDateWithformat:@"yyyy-MM-dd"];
	NSDictionary *dictionary = [self.editedTasksDict valueForKey:key];
	if (!dictionary) {
		return nil;
	}
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"syncId == %@", syncId];
	NSArray *foundTasks = [[dictionary valueForKey:@"content"] filteredArrayUsingPredicate:predicate];
	
	return (foundTasks.count > 0) ? [foundTasks objectAtIndex:0] : nil;
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
	[[NSNotificationCenter defaultCenter]postNotificationName:TasksGraphUpdatedSinceDidLoadNotification 
													   object:[self.editedTasksDict valueForKey:@"content"]];
}

#pragma mark -
#pragma mark Syncing

- (BOOL)groupOperationsShouldUseSerialQueue
{
	return ([[self.groupsOutOfSyncDict valueForKey:AddedKey]count] > 0 ||
			[[self.groupsOutOfSyncDict valueForKey:UpdatedKey]count] > 0 ||
			[[self.groupsOutOfSyncDict valueForKey:DeletedKey]count] > 0);
}

#define GroupsOutOfSyncKey @"GroupsOutOfSync"

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

- (void)saveGroupsOutOfSync
{
	[self.groupsOutOfSyncDict saveDictForKey:GroupsOutOfSyncKey];
}

- (BOOL)taskOperationsShouldUseSerialQueue
{
	return ([[self.tasksOutOfSyncDict valueForKey:AddedKey]count] > 0 ||
			[[self.tasksOutOfSyncDict valueForKey:UpdatedKey]count] > 0 ||
			[[self.tasksOutOfSyncDict valueForKey:DeletedKey]count] > 0);
}

#define TasksOutOfSyncKey @"TasksOutOfSync"

- (NSMutableDictionary *)tasksOutOfSyncDict
{
	if (!tasksOutOfSyncDict) {
		tasksOutOfSyncDict = [[NSDictionary savedDictForKey:TasksOutOfSyncKey]mutableCopy]; 
		if (!tasksOutOfSyncDict) {
			tasksOutOfSyncDict = [[NSMutableDictionary alloc]init];
		}
	}
	
	return tasksOutOfSyncDict;
}

- (void)saveTasksOutOfSync
{
	[self.tasksOutOfSyncDict saveDictForKey:TasksOutOfSyncKey];
}

#pragma mark -
#pragma mark Cache Clearing

- (void)clearCachedData
{
	[self.tasksOutOfSyncDict removeAllObjects];
	[self saveTasksOutOfSync];
	[self.groupsOutOfSyncDict removeAllObjects];
	[self saveGroupsOutOfSync];
	[self.groupsDict removeAllObjects];
	[self saveGroups];
	[self.tasksWithGroupIdDict removeAllObjects];
	[self saveTasksWithGroupId];
	[self.tasksWithDueDict removeAllObjects];
	[self saveTasksWithDue];
	[self.tasksDueTodayDict removeAllObjects];
	[self saveTasksDueToday];
	[self.tasksWithLatitudeDict removeAllObjects];
	[self saveTasksWithLatitude];
	[self.editedTasksDict removeAllObjects];
	[self saveEditedTasks];
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[tasksOutOfSyncDict release];
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
