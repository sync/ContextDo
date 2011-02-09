#import "CTXDONotificationsServices.h"

@interface CTXDONotificationsServices (private)

- (NSDictionary *)userInfoForTask:(Task *)task today:(BOOL)today;
- (UILocalNotification *)hasLocalNotificationForTaskId:(NSNumber *)taskId today:(BOOL)today;
- (Task *)taskForUserInfo:(NSDictionary *)userInfo;
- (void)restoreDueTasksfromCached;
- (void)restoreWithinTasksFromCached;
- (void)reloadTodayTasks:(NSArray *)newTasks;
- (void)reloadWithinTasks:(NSArray *)newTasks;

@end


@implementation CTXDONotificationsServices

SYNTHESIZE_SINGLETON_FOR_CLASS(CTXDONotificationsServices);

- (id) init
{
	self = [super init];
	if (self != nil) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreDueTasksfromCached) name:TasksGraphDueTodayDidLoadNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldCheckTodayTasks:) name:TasksDueTodayDidLoadNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreWithinTasksFromCached) name:TasksGraphWithinDidLoadNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldCheckWithinTasks:) name:TasksWithinDidLoadNotification object:nil];
	}
	return self;
}


#pragma mark -
#pragma mark Main

- (void)refreshTasksForLocalNotification
{
	[self restoreDueTasksfromCached];
    [self restoreWithinTasksFromCached];
    
    [[APIServices sharedAPIServices]refreshTasksDueToday];
}


- (void)parseNotification:(UILocalNotification *)notification
{
	if (!notification && !notification.userInfo) {
		return;
	}
	
	Task *notificationTask = [NSKeyedUnarchiver unarchiveObjectWithData:[notification.userInfo valueForKey:@"taskData"]];
	if (notificationTask) {
		[[AppDelegate sharedAppDelegate] showTask:notificationTask animated:TRUE];
	} else {
		[[AppDelegate sharedAppDelegate] showNearTasksAnimated:TRUE];
	}
}

#pragma mark -
#pragma mark Utilities

- (NSDictionary *)userInfoForTask:(Task *)task today:(BOOL)today
{
	NSData *taskData = [NSKeyedArchiver archivedDataWithRootObject:task];
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
			taskData, @"taskData",
			[NSNumber numberWithBool:today], @"today",
			nil
			];
}

- (Task *)taskForUserInfo:(NSDictionary *)userInfo
{
	Task *notificationTask = [NSKeyedUnarchiver unarchiveObjectWithData:[userInfo valueForKey:@"taskData"]];
	return notificationTask;
}

- (UILocalNotification *)hasLocalNotificationForTaskId:(NSNumber *)taskId today:(BOOL)today
{
	NSArray *notifications =  [[UIApplication sharedApplication]scheduledLocalNotifications];
	for (UILocalNotification *notification in notifications) {
		Task *notificationTask = [NSKeyedUnarchiver unarchiveObjectWithData:[notification.userInfo valueForKey:@"taskData"]];
		if (!notificationTask) {
			return nil;
		}
		
		NSNumber *notificationTaskId = notificationTask.taskId;
		BOOL notificationCurrentToday = [[notification.userInfo valueForKey:@"today"]boolValue];
		if ([taskId isEqualToNumber:notificationTaskId] && today == notificationCurrentToday) {
			return notification;
		}
	}
	return nil;
}

#pragma mark -
#pragma mark Within

- (void)restoreWithinTasksFromCached
{
    NSArray *archivedContent = [CacheServices sharedCacheServices].tasksWithin;
    [self reloadWithinTasks:archivedContent];
}

- (void)shouldCheckWithinTasks:(NSNotification *)notification
{
	NSArray *newTasks = [notification object];
    [self reloadWithinTasks:newTasks];
}

- (void)reloadWithinTasks:(NSArray *)newTasks
{
    NSArray *notifications =  [[UIApplication sharedApplication]scheduledLocalNotifications];
	for (UILocalNotification *olderNotification in notifications) {
		if (!olderNotification.fireDate) {
			[[UIApplication sharedApplication]cancelLocalNotification:olderNotification];
		}
	}
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isClose == %@", [NSNumber numberWithBool:TRUE]];
	NSArray *closeTasks = [newTasks filteredArrayUsingPredicate:predicate];
	
	UIDevice* device = [UIDevice currentDevice];
	UIApplication *app = [UIApplication sharedApplication];
	
	if (closeTasks.count == 1) {
		Task *task = [closeTasks objectAtIndex:0];
		
		if ([device respondsToSelector:@selector(isMultitaskingSupported)] && device.isMultitaskingSupported) {
			UILocalNotification *previousNotification = [self hasLocalNotificationForTaskId:task.taskId today:TRUE];
			if (previousNotification) {
				[[UIApplication sharedApplication]cancelLocalNotification:previousNotification];
			}
			UILocalNotification *notification = [[[UILocalNotification alloc] init]autorelease];
			notification.fireDate  = nil;
			notification.timeZone  = [NSTimeZone systemTimeZone];
			notification.alertBody = [NSString stringWithFormat:@"You are close to %@, would you like to view it?", task.name];
			notification.applicationIconBadgeNumber = 1;
			notification.soundName= UILocalNotificationDefaultSoundName;
			notification.userInfo = [self userInfoForTask:task today:FALSE];
			[app scheduleLocalNotification:notification];
		}
	} else if (closeTasks.count > 1) {
		if ([device respondsToSelector:@selector(isMultitaskingSupported)] && device.isMultitaskingSupported) {
			UILocalNotification *notification = [[[UILocalNotification alloc] init]autorelease];
			notification.fireDate  = nil;
			notification.timeZone  = [NSTimeZone systemTimeZone];
			notification.alertBody = @"More than one task are close to your current location, would you like to see them?";
			notification.applicationIconBadgeNumber = closeTasks.count;
			notification.soundName= UILocalNotificationDefaultSoundName;
			notification.userInfo = [self userInfoForTask:nil today:FALSE];
			[app scheduleLocalNotification:notification];
		}
	}
}

#pragma mark -
#pragma mark Today

- (void)restoreDueTasksfromCached
{
	NSString *due = [[NSDate date] getUTCDateWithformat:@"yyyy-MM-dd"];
    NSArray *archivedContent = [[CacheServices sharedCacheServices].tasksDueTodayDict
                                valueForKeyPath:[NSString stringWithFormat:@"%@.content", due]];
    [self reloadTodayTasks:archivedContent];
}

- (void)shouldCheckTodayTasks:(NSNotification *)notification
{
	NSArray *newTasks =[notification object];
    [self reloadTodayTasks:newTasks];
}

- (void)reloadTodayTasks:(NSArray *)newTasks
{
    NSArray *notifications =  [[UIApplication sharedApplication]scheduledLocalNotifications];
	for (UILocalNotification *olderNotification in notifications) {
		if (olderNotification.fireDate) {
			[[UIApplication sharedApplication]cancelLocalNotification:olderNotification];
		}
	}
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dueAt != nil && expired == %@", [NSNumber numberWithBool:FALSE]];
	NSArray *dueTasks = [newTasks filteredArrayUsingPredicate:predicate];
	
	UIDevice* device = [UIDevice currentDevice];
	UIApplication *app = [UIApplication sharedApplication];
	
	for (Task *task in dueTasks) {
		if ([device respondsToSelector:@selector(isMultitaskingSupported)] && device.isMultitaskingSupported) {
			UILocalNotification *previousNotification = [self hasLocalNotificationForTaskId:task.taskId today:TRUE];
			if (previousNotification) {
				[[UIApplication sharedApplication]cancelLocalNotification:previousNotification];
			}
			UILocalNotification *notification = [[[UILocalNotification alloc] init]autorelease];
			notification.fireDate  = task.dueAt;;
			notification.timeZone  = [NSTimeZone systemTimeZone];
			notification.alertBody = [NSString stringWithFormat:@"%@ is due, would you like to see it?", task.name];
			notification.applicationIconBadgeNumber = 1;
			notification.soundName= UILocalNotificationDefaultSoundName;
			notification.userInfo = [self userInfoForTask:task today:TRUE];
			[app scheduleLocalNotification:notification];
		}
	}
}

@end
