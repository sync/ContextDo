#import "APIServices.h"
#import "BaseASIServices+Utils.h"
#import "APIServices+Parsing.h"
#import "NSDate+Extensions.h"
#import "Reachability.h"
#import "SFHFKeychainUtils.h"
#import "ObjectiveSupport.h"
#import <Parse/Parse.h>
#import "PFUser+CTXDO.h"

@implementation APIServices

SYNTHESIZE_SINGLETON_FOR_CLASS(APIServices)

@synthesize serialNetworkQueue;

#pragma mark -
#pragma mark Serial Queue

- (ASINetworkQueue *)serialNetworkQueue
{
	if (!serialNetworkQueue) {
		serialNetworkQueue = [[ASINetworkQueue alloc] init];
		[serialNetworkQueue setMaxConcurrentOperationCount:1];
		if ([self respondsToSelector:@selector(fetchStarted:)]) {
			[serialNetworkQueue setRequestDidStartSelector:@selector(fetchStarted:)];
		}
		if ([self respondsToSelector:@selector(fetchCompleted:)]) {
			[serialNetworkQueue setRequestDidFinishSelector:@selector(fetchCompleted:)];
		}
		if ([self respondsToSelector:@selector(fetchFailed:)]) {
			[serialNetworkQueue setRequestDidFailSelector:@selector(fetchFailed:)];
		}
		if ([self respondsToSelector:@selector(queueFinished:)]) {
			[serialNetworkQueue setQueueDidFinishSelector:@selector(queueFinished:)];
		}
		
		[serialNetworkQueue setDelegate:self];
	}
	
	return serialNetworkQueue;
}

#pragma mark -
#pragma mark Request Constructors

- (ASIHTTPRequest *)requestWithUrl:(NSString *)url
{
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
	request.numberOfTimesToRetryOnTimeout = 1;
	request.timeOutSeconds = RequestTimeOutSeconds;
	
	[request addRequestHeader:@"Content-Type" value:@"application/json"];
	[request addRequestHeader:@"Accept" value:@"application/json"];
	
	request.allowCompressedResponse = TRUE;
	request.shouldAttemptPersistentConnection = FALSE;
	
	return request;
}

- (ASIFormDataRequest *)formRequestWithUrl:(NSString *)url
{
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
	request.numberOfTimesToRetryOnTimeout = 2;
	request.timeOutSeconds = RequestTimeOutSeconds;
	[request setRequestMethod:@"POST"];
	
	[request addRequestHeader:@"Content-Type" value:@"application/json"];
	[request addRequestHeader:@"Accept" value:@"application/json"];
	
	request.allowCompressedResponse = TRUE;
	request.shouldAttemptPersistentConnection = FALSE;
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	[request setShouldContinueWhenAppEntersBackground:YES];
#endif
	
	return request;
}

#pragma mark -
#pragma mark Groups

- (void)refreshGroups
{
	NSString *notificationName = GroupsDidLoadNotification;
	NSString *path = @"groups";
    
    NSString *url = CTXDOURL(BASE_URL, GROUPS_PATH);
    [self downloadContentForUrl:url withObject:nil path:path notificationName:notificationName];
}

- (void)addGroup:(Group *)group
{
	if (!group) {
		return;
	}
	
	if (!group.syncId) {
		group.syncId = [NSNumber numberWithInteger:[[[NSProcessInfo processInfo] globallyUniqueString]hash]];
	}
	
	NSString *notificationName = GroupAddNotification;
	NSString *path = @"addGroupWithName";
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  path, @"path",
							  notificationName, @"notificationName",
							  group, @"object",
							  nil];
	
	NSString *url = CTXDOURL(BASE_URL, GROUPS_PATH);
	ASIFormDataRequest *request = [self formRequestWithUrl:url];	
	request.userInfo = userInfo;
	request.delegate = self;
	
	NSArray *excluding = [NSArray arrayWithObjects:
						  @"groupId",
						  @"taskWithin",
						  @"updatedAt",
						  @"createdAt",
						  @"dueCount",
						  @"expiredCount",
						  @"userId",
						  @"syncId",
						  nil];
	NSString *string = [group toJSONExcluding:excluding];
	[request appendPostData:[string dataUsingEncoding:NSUTF8StringEncoding]];
	
	[self.serialNetworkQueue addOperation:request];
	[self.serialNetworkQueue go];
	
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStartLoadingForKey:[self notificationNameForRequest:request]];
}

- (void)updateGroup:(Group *)group
{
	if (!group) {
		return;
	}
	
	if (!group.syncId) {
		group.syncId = [NSNumber numberWithInteger:[[[NSProcessInfo processInfo] globallyUniqueString]hash]];
	}
	
	NSString *notificationName = GroupEditNotification;
	NSString *path = @"addGroupWithName";
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  path, @"path",
							  notificationName, @"notificationName",
							  group, @"object",
							  nil];
	
	NSString *url = GROUPURL(BASE_URL, GROUPS_PATH, group.groupId);
	ASIFormDataRequest *request = [self formRequestWithUrl:url];	
	request.userInfo = userInfo;
	request.delegate = self;
	
	[request setRequestMethod:@"PUT"];
	
	NSArray *excluding = [NSArray arrayWithObjects:
						  @"groupId",
						  @"taskWithin",
						  @"updatedAt",
						  @"createdAt",
						  @"dueCount",
						  @"expiredCount",
						  @"userId",
						  @"syncId",
						  nil];
	NSString *string = [group toJSONExcluding:excluding];
	[request appendPostData:[string dataUsingEncoding:NSUTF8StringEncoding]];
	
	
	[self.serialNetworkQueue addOperation:request];
	[self.serialNetworkQueue go];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStartLoadingForKey:[self notificationNameForRequest:request]];
}

- (void)deleteGroup:(Group *)group
{
	if (!group) {
		return;
	}
	
	if (!group.syncId) {
		group.syncId = [NSNumber numberWithInteger:[[[NSProcessInfo processInfo] globallyUniqueString]hash]];
	}
	
	NSString *notificationName = GroupDeleteNotification;
	NSString *path = @"addGroupWithName";
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  path, @"path",
							  notificationName, @"notificationName",
							  group, @"object",
							  nil];
	
	NSString *url = GROUPURL(BASE_URL, GROUPS_PATH, group.groupId);
	ASIFormDataRequest *request = [self formRequestWithUrl:url];	
	request.userInfo = userInfo;
	request.delegate = self;
	
	[request setRequestMethod:@"DELETE"];
	
	[self.serialNetworkQueue addOperation:request];
	[self.serialNetworkQueue go];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStartLoadingForKey:[self notificationNameForRequest:request]];
}

- (void)syncGroups
{
	if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable) {
		if (self.serialNetworkQueue.requestsCount > 0) {
			[self performSelector:@selector(syncGroups) withObject:nil afterDelay:0.5];
		}
	}
}

#pragma mark -
#pragma mark Tasks

- (void)refreshTasksWithGroupId:(NSNumber *)groupId
{
	if (!groupId) {
		return;
	}
	
	NSString *notificationName = TasksDidLoadNotification;
	NSString *path = @"tasksWithGroupId";
	
	NSString *url = TASKSURL(BASE_URL, TASKS_PATH, groupId);
	[self downloadContentForUrl:url withObject:[groupId stringValue] path:path notificationName:notificationName];
}

- (void)refreshTasksWithDue:(NSString *)due
{
	if (due.length == 0) {
		return;
	}
	
	NSString *notificationName = TasksDueDidLoadNotification;
	NSString *path = @"tasksWithDue";
	
	NSString *url = TASKSDUEURL(BASE_URL, TASKS_PATH, due);
	[self downloadContentForUrl:url withObject:due path:path notificationName:notificationName];
}

- (void)refreshTasksDueToday
{
	NSString *notificationName = TasksDueTodayDidLoadNotification;
	NSString *path = @"tasksDueToday";
	
	NSString *due = [[NSDate date] getUTCDateWithformat:@"yyyy-MM-dd"];
	
	NSString *url = TASKSDUEURL(BASE_URL, TASKS_PATH, due);
	[self downloadContentForUrl:url withObject:due path:path notificationName:notificationName];
}

- (void)refreshTasksWithLatitude:(CLLocationDegrees)latitude
					   longitude:(CLLocationDegrees)longitude
{
	NSString *notificationName = TasksWithinDidLoadNotification;
	NSString *path = @"tasksWithLatitude";
	
	NSString *latLngString = [NSString stringWithFormat:@"%f,%f", latitude, longitude];
	
	NSString *url = TASKSWITHINURL(BASE_URL, TASKS_PATH, latitude, longitude, [PFUser currentUser].alertsDistanceWithin);
	[self downloadContentForUrl:url withObject:latLngString path:path notificationName:notificationName];
}

- (void)refreshTasksWithQuery:(NSString *)query;
{
	if (query.length == 0) {
		return;
	}
	
	NSString *notificationName = TasksSearchDidLoadNotification;
	NSString *path = @"tasksWithQuery";
	
	NSString *url = TASKSSEARCHURL(BASE_URL, TASKS_PATH, [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
	[self downloadContentForUrl:url withObject:query path:path notificationName:notificationName];
}

- (void)refreshTasksEdited
{
	NSString *notificationName = TasksUpdatedSinceDidLoadNotification;
	NSString *path = @"editedTasks";
	
	NSString *editedAt = [[NSDate date] getUTCDateWithformat:@"yyyy-MM-dd"];
	
	NSString *url = TASKSUPDATEDSINCEURL(BASE_URL, TASKS_PATH, [[NSDate date] getUTCDateWithformat:@"yyyy-MM-dd"]);
	[self downloadContentForUrl:url withObject:editedAt path:path notificationName:notificationName];
}

- (void)addTask:(Task *)task
{
	if (!task) {
		return;
	}
	
	if (!task.syncId) {
		task.syncId = [NSNumber numberWithInteger:[[[NSProcessInfo processInfo] globallyUniqueString]hash]];
	}
	
	NSString *notificationName = TaskAddNotification;
	NSString *path = @"addTask";
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  path, @"path",
							  notificationName, @"notificationName",
							  task, @"object",
							  nil];
	
	NSString *url = TASKURL(BASE_URL, GROUPS_PATH, task.groupId, nil);
	ASIFormDataRequest *request = [self formRequestWithUrl:url];	
	request.userInfo = userInfo;
	request.delegate = self;
	
	NSArray *excluding = [NSArray arrayWithObjects:
						  @"groupName",
						  @"taskId",
						  @"groupId",
						  @"updatedAt",
						  @"createdAt",
						  @"formattedContact",
						  @"distance",
						  @"isClose",
						  @"expired",
						  @"completed",
						  @"dueToday",
						  @"isFacebook",
						  @"latLngString",
						  @"syncId",
						  @"editedToday",
						  @"completedWithin24hours",
						  nil];
	NSString *string = [task toJSONExcluding:excluding];
	[request appendPostData:[string dataUsingEncoding:NSUTF8StringEncoding]];
	
	[self.serialNetworkQueue addOperation:request];
	[self.serialNetworkQueue go];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStartLoadingForKey:[self notificationNameForRequest:request]];
}

- (void)updateTask:(Task *)task
{
	if (!task) {
		return;
	}
	
	if (!task.syncId) {
		task.syncId = [NSNumber numberWithInteger:[[[NSProcessInfo processInfo] globallyUniqueString]hash]];
	}
	
	NSString *notificationName = TaskEditNotification;
	NSString *path = @"updateTask";
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  path, @"path",
							  notificationName, @"notificationName",
							  task, @"object",
							  nil];
	
	NSString *url = TASKURL(BASE_URL, GROUPS_PATH, task.groupId, task.taskId);
	ASIFormDataRequest *request = [self formRequestWithUrl:url];	
	request.userInfo = userInfo;
	request.delegate = self;
	
	[request setRequestMethod:@"PUT"];
	
	NSArray *excluding = [NSArray arrayWithObjects:
						  @"groupName",
						  @"taskId",
						  @"groupId",
						  @"updatedAt",
						  @"createdAt",
						  @"formattedContact",
						  @"distance",
						  @"isClose",
						  @"expired",
						  @"completed",
						  @"dueToday",
						  @"isFacebook",
						  @"latLngString",
						  @"syncId",
						  @"editedToday",
						  @"completedWithin24hours",
						  nil];
	NSString *string = [task toJSONExcluding:excluding];
	[request appendPostData:[string dataUsingEncoding:NSUTF8StringEncoding]];
	
	[self.serialNetworkQueue addOperation:request];
	[self.serialNetworkQueue go];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStartLoadingForKey:[self notificationNameForRequest:request]];
}

- (void)deleteTask:(Task *)task
{
	if (!task) {
		return;
	}
	
	if (!task.syncId) {
		task.syncId = [NSNumber numberWithInteger:[[[NSProcessInfo processInfo] globallyUniqueString]hash]];
    }
	
	NSString *notificationName = TaskDeleteNotification;
	NSString *path = @"deleteTaskWitId";
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  path, @"path",
							  notificationName, @"notificationName",
							  task, @"object",
							  nil];
	
	NSString *url = TASKURL(BASE_URL, GROUPS_PATH, task.groupId, task.taskId);
	ASIFormDataRequest *request = [self formRequestWithUrl:url];	
	request.userInfo = userInfo;
	request.delegate = self;
	
	[request setRequestMethod:@"DELETE"];
	
	[self.serialNetworkQueue addOperation:request];
	[self.serialNetworkQueue go];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStartLoadingForKey:[self notificationNameForRequest:request]];
}

#pragma mark -
#pragma mark Content Management

- (void)downloadContentForUrl:(NSString *)url withObject:(id)object path:(NSString *)path notificationName:(NSString *)notificationName
{
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  path, @"path",
							  notificationName, @"notificationName",
							  object, @"object",
							  nil];
	
	ASIHTTPRequest *request = [self requestWithUrl:url];
	request.userInfo = userInfo;
	request.delegate = self;
	
	[self.networkQueue addOperation:request];
	[self.networkQueue go];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStartLoadingForKey:[self notificationNameForRequest:request]];
}

- (void)downloadSeriallyContentForUrl:(NSString *)url withObject:(id)object path:(NSString *)path notificationName:(NSString *)notificationName
{
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  path, @"path",
							  notificationName, @"notificationName",
							  object, @"object",
							  nil];
	
	ASIHTTPRequest *request = [self requestWithUrl:url];
	request.userInfo = userInfo;
	request.delegate = self;
	
	[self.serialNetworkQueue addOperation:request];
	[self.serialNetworkQueue go];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStartLoadingForKey:[self notificationNameForRequest:request]];
}

#pragma mark -
#pragma mark ASIHTTPRequest delegate

- (void)fetchCompleted:(ASIHTTPRequest *)request
{
	NSDictionary *info = request.userInfo;
	NSString *path = [info valueForKey:@"path"];
	
    if ([path isEqualToString:@"resetPasswordWithUsername"]) {
		[self parseResetPassword:request];
	} else if ([path isEqualToString:@"groups"]) {
		[self parseGroups:request];
	} else if ([path isEqualToString:@"tasksWithGroupId"]|| 
			   [path isEqualToString:@"tasksWithDue"] ||
			   [path isEqualToString:@"tasksWithLatitude"] ||
			   [path isEqualToString:@"tasksWithQuery"] || 
			   [path isEqualToString:@"editedTasks"] || 
			   [path isEqualToString:@"tasksDueToday"]) {
		[self parseTasks:request];
	} else if ([path isEqualToString:@"addGroupWithName"]|| 
			   [path isEqualToString:@"editGroupWithId"] ||
			   [path isEqualToString:@"deleteGroupWitId"]) {
		[self parseGroup:request];
	} else if ([path isEqualToString:@"addTask"]|| 
			   [path isEqualToString:@"updateTask"] ||
			   [path isEqualToString:@"deleteTaskWitId"]) {
		[self parseTask:request];
	}
	
	DLog(@"fetch completed for url:%@", request.originalURL);
}

- (void)fetchFailed:(ASIHTTPRequest *)request
{
	DLog(@"fetch failed for url:%@ error:%@", request.originalURL, [request.error localizedDescription]);
	
	if ([request responseStatusCode] == 401) {
		if ([request.url.absoluteString hasSuffix:LOGIN_PATH]) {
			[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]showErrorMsg:@"Wrong Username or Password!" forKey:[self notificationNameForRequest:request]];
		} else {
			[[AppDelegate sharedAppDelegate]showLoginView:TRUE];
		}
	} else {
		//[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]showErrorMsg:[request.error localizedDescription] forKey:[self notificationNameForRequest:request]];
	}
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStopLoadingForKey:[self notificationNameForRequest:request]];
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[serialNetworkQueue release];
	
	[super dealloc];
}

@end
