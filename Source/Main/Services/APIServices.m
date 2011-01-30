#import "APIServices.h"
#import "BaseASIServices+Utils.h"
#import "APIServices+Parsing.h"
#import "NSDate+Extensions.h"

@implementation APIServices

SYNTHESIZE_SINGLETON_FOR_CLASS(APIServices)

#pragma mark -
#pragma mark Request Constructors

- (ASIHTTPRequest *)requestWithUrl:(NSString *)url
{
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
	request.numberOfTimesToRetryOnTimeout = 0;
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
#pragma mark Storage

- (NSString *)apiToken
{	
	return [[NSUserDefaults standardUserDefaults]stringForKey:APITokenUserDefaults];
}

- (void)setApiToken:(NSString *)apiToken
{
	if (!apiToken) {
		[[NSUserDefaults standardUserDefaults]removeObjectForKey:APITokenUserDefaults];
	} else {
		[[NSUserDefaults standardUserDefaults]setValue:apiToken forKey:APITokenUserDefaults];
	}
	
	[[NSUserDefaults standardUserDefaults]synchronize];
}

- (NSString *)username
{
	if (self.apiToken && APITokenEabled) {
		return self.apiToken;
	}
	return [[NSUserDefaults standardUserDefaults]stringForKey:UsernameUserDefaults];
}

- (void)setUsername:(NSString *)username
{
	if (!username) {
		[[NSUserDefaults standardUserDefaults]removeObjectForKey:UsernameUserDefaults];
	} else {
		[[NSUserDefaults standardUserDefaults]setValue:username forKey:UsernameUserDefaults];
	}
	
	[[NSUserDefaults standardUserDefaults]synchronize];
}

- (NSString *)password
{
	if (self.apiToken && APITokenEabled) {
		return @"X";
	}
	return [[NSUserDefaults standardUserDefaults]stringForKey:PasswordUserDefaults];
}

- (void)setPassword:(NSString *)password
{
	if (!password) {
		[[NSUserDefaults standardUserDefaults]removeObjectForKey:PasswordUserDefaults];
	} else {
		[[NSUserDefaults standardUserDefaults]setValue:password forKey:PasswordUserDefaults];
	}
	
	[[NSUserDefaults standardUserDefaults]synchronize];
}

#pragma mark -
#pragma mark Login

- (void)loginWithUsername:(NSString *)aUsername password:(NSString *)aPassword
{
	if (!aUsername || !aPassword) {
		return;
	}
	
	self.username = nil;
	self.password = nil;
	
	NSString *notificationName = UserDidLoginNotification;
	NSString *path = @"login";
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  path, @"path",
							  notificationName, @"notificationName",
							  nil];
	
	NSString *url = CTXDOURL(BASE_URL, LOGIN_PATH);
	ASIHTTPRequest *request = [self requestWithUrl:url];	
	request.userInfo = userInfo;
	request.delegate = self;
	
	[request setUsername:aUsername];
	[request setPassword:aPassword];
	
	[self.networkQueue addOperation:request];
	[self.networkQueue go];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStartLoadingForKey:[self notificationNameForRequest:request]];
}

#pragma mark -
#pragma mark Registration

- (void)registerWithUsername:(NSString *)aUsername password:(NSString *)aPassword
{
	if (!aUsername || !aPassword) {
		return;
	}
	
	NSString *notificationName = UserDidRegisterNotification;
	NSString *path = @"register";
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  path, @"path",
							  notificationName, @"notificationName",
							  aUsername, @"username",
							  aPassword, @"password",
							  nil];
	
	NSString *url = CTXDOURL(BASE_URL, REGISTER_PATH);
	ASIFormDataRequest *request = [self formRequestWithUrl:url];
	request.userInfo = userInfo;
	request.delegate = self;
	
	[request setPostValue:aUsername forKey:@"user[email]"];
	[request setPostValue:aPassword forKey:@"user[password]"];
	[request setPostValue:aPassword forKey:@"user[password_confirmation]"];
	
	[request addRequestHeader:@"X-Requested-With" value:@"XMLHttpRequest"];
	
	[self.networkQueue addOperation:request];
	[self.networkQueue go];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStartLoadingForKey:[self notificationNameForRequest:request]];	
}

#pragma mark -
#pragma mark Reset Password

- (void)resetPasswordWithUsername:(NSString *)aUsername
{
	if (!aUsername) {
		return;
	}
	
	NSString *notificationName = UserDidResetPasswordNotification;
	NSString *path = @"resetPasswordWithUsername";
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  path, @"path",
							  notificationName, @"notificationName",
							  nil];
	
	NSString *url = CTXDOURL(BASE_URL, RESET_PASSWORD_PATH);
	ASIFormDataRequest *request = [self formRequestWithUrl:url];	
	request.userInfo = userInfo;
	request.delegate = self;
	
	[request setPostValue:aUsername forKey:@"user[email]"];
	
	[self.networkQueue addOperation:request];
	[self.networkQueue go];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStartLoadingForKey:[self notificationNameForRequest:request]];
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
						  nil];
	NSString *string = [group toJSONExcluding:excluding];
	[request appendPostData:[string dataUsingEncoding:NSUTF8StringEncoding]];
	
	[self.networkQueue addOperation:request];
	[self.networkQueue go];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStartLoadingForKey:[self notificationNameForRequest:request]];
}


- (void)updateGroup:(Group *)group
{
	if (!group) {
		return;
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
						  nil];
	NSString *string = [group toJSONExcluding:excluding];
	[request appendPostData:[string dataUsingEncoding:NSUTF8StringEncoding]];
	
	[self.networkQueue addOperation:request];
	[self.networkQueue go];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStartLoadingForKey:[self notificationNameForRequest:request]];
}

- (void)deleteGroup:(Group *)group
{
	if (!group) {
		return;
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
	
	[self.networkQueue addOperation:request];
	[self.networkQueue go];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStartLoadingForKey:[self notificationNameForRequest:request]];
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
	[self downloadContentForUrl:url withObject:nil path:path notificationName:notificationName];
}

- (void)refreshTasksWithDue:(NSString *)due
{
	if (due.length == 0) {
		return;
	}
	
	NSString *notificationName = TasksDueDidLoadNotification;
	NSString *path = @"tasksWithDue";
	
	NSString *url = TASKSDUEURL(BASE_URL, TASKS_PATH, due);
	[self downloadContentForUrl:url withObject:nil path:path notificationName:notificationName];
}

- (void)refreshTasksDueToday
{
	NSString *notificationName = TasksDueTodayDidLoadNotification;
	NSString *path = @"tasksDueToday";
	
	NSString *url = TASKSDUEURL(BASE_URL, TASKS_PATH, [[NSDate date] getUTCDateWithformat:@"yyyy-MM-dd"]);
	[self downloadContentForUrl:url withObject:nil path:path notificationName:notificationName];
}

- (void)refreshTasksWithLatitude:(CLLocationDegrees)latitude
					   longitude:(CLLocationDegrees)longitude 
					inBackground:(BOOL)background
{
	NSString *notificationName = (!background) ? TasksWithinDidLoadNotification : TasksWithinBackgroundDidLoadNotification;
	NSString *path = @"tasksWithLatitude";
	
	NSString *url = TASKSWITHINURL(BASE_URL, TASKS_PATH, latitude, longitude, self.alertsDistanceWithin.floatValue);
	[self downloadContentForUrl:url withObject:nil path:path notificationName:notificationName];
}

- (void)refreshTasksWithQuery:(NSString *)query;
{
	if (query.length == 0) {
		return;
	}
	
	NSString *notificationName = TasksSearchDidLoadNotification;
	NSString *path = @"tasksWithQuery";
	
	NSString *url = TASKSSEARCHURL(BASE_URL, TASKS_PATH, query);
	[self downloadContentForUrl:url withObject:nil path:path notificationName:notificationName];
}

- (void)refreshTasksEdited
{
	NSString *notificationName = TasksUpdatedSinceDidLoadNotification;
	NSString *path = @"editedTasks";
	
	NSString *url = TASKSUPDATEDSINCEURL(BASE_URL, TASKS_PATH, [[NSDate date] getUTCDateWithformat:@"yyyy-MM-dd"]);
	[self downloadContentForUrl:url withObject:nil path:path notificationName:notificationName];
}

- (void)addTask:(Task *)task
{
	if (!task) {
		return;
	}
	
	NSString *notificationName = TaskAddNotification;
	NSString *path = @"addTask";
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  path, @"path",
							  notificationName, @"notificationName",
							  task, @"object",
							  nil];
	
	NSString *url = TASKURL(BASE_URL, GROUPS_PATH, task.groupId, task.taskId);
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
						  nil];
	NSString *string = [task toJSONExcluding:excluding];
	[request appendPostData:[string dataUsingEncoding:NSUTF8StringEncoding]];
	
	[self.networkQueue addOperation:request];
	[self.networkQueue go];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStartLoadingForKey:[self notificationNameForRequest:request]];
}

- (void)updateTask:(Task *)task
{
	if (!task) {
		return;
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
						  nil];
	NSString *string = [task toJSONExcluding:excluding];
	[request appendPostData:[string dataUsingEncoding:NSUTF8StringEncoding]];
	
	[self.networkQueue addOperation:request];
	[self.networkQueue go];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStartLoadingForKey:[self notificationNameForRequest:request]];
}

- (void)deleteTask:(Task *)task
{
	if (!task) {
		return;
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
	
	[self.networkQueue addOperation:request];
	[self.networkQueue go];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStartLoadingForKey:[self notificationNameForRequest:request]];
}

#pragma mark -
#pragma mark User

- (void)refreshUser
{
	NSString *notificationName = UserDidLoadNotification;
	NSString *path = @"user";
	
	NSString *url = CTXDOURL(BASE_URL, USER_PATH);
	[self downloadContentForUrl:url withObject:nil path:path notificationName:notificationName];
}

- (void)updateUser:(User *)user
{
	if (!user) {
		return;
	}
	
	NSString *notificationName = UserEditNotification;
	NSString *path = @"updateUser";
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  path, @"path",
							  notificationName, @"notificationName",
							  user, @"object",
							  nil];
	
	NSString *url = CTXDOURL(BASE_URL, USER_PATH);
	ASIFormDataRequest *request = [self formRequestWithUrl:url];	
	request.userInfo = userInfo;
	request.delegate = self;
	
	[request setRequestMethod:@"PUT"];
	
	NSString *string = [user toJSON];
	[request appendPostData:[string dataUsingEncoding:NSUTF8StringEncoding]];
	
	[self.networkQueue addOperation:request];
	[self.networkQueue go];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStartLoadingForKey:[self notificationNameForRequest:request]];
}

- (NSNumber *)alertsDistanceWithin
{
	return [[NSUserDefaults standardUserDefaults]objectForKey:AlertsDistanceWithin];
}

- (void)setAlertsDistanceWithin:(NSNumber *)alertsDistanceWithin
{
	if (!alertsDistanceWithin) {
		[[NSUserDefaults standardUserDefaults]setValue:[NSNumber numberWithInteger:AlertsDistanceWithinDefaultValue] forKey:AlertsDistanceWithin];
	} else {
		[[NSUserDefaults standardUserDefaults]setValue:alertsDistanceWithin forKey:AlertsDistanceWithin];
	}
	
	[[NSUserDefaults standardUserDefaults]synchronize];
}

- (CGFloat)alertsDistancKmToSliderValue:(CGFloat)value
{
	CGFloat sliderValue = 0.0;
	if (value < 0.25) {
		sliderValue = 0.0;
	} else if (value < 0.75) {
		sliderValue = 1.0;
	} else if (value < 2.0) {
		sliderValue = 2.0;
	} else if (value < 4.0) {
		sliderValue = 3.0;
	} else {
		sliderValue = 5.0;
	}
	return sliderValue;
}

- (CGFloat)sliderValueToAlertsDistancKm:(CGFloat)value
{
	CGFloat kmValue = 0.0;
	if (value < 0.5) {
		kmValue = 0.1;
	} else if (value < 1.5) {
		kmValue = 0.5;
	} else if (value < 2.5) {
		kmValue = 1.0;
	} else if (value < 3.5) {
		kmValue = 3.0;
	} else {
		kmValue = 5.0;
	}
	return kmValue;
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
	
	request.username = self.username;
	request.password = self.password;
	
	[self.networkQueue addOperation:request];
	[self.networkQueue go];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStartLoadingForKey:[self notificationNameForRequest:request]];
}

#pragma mark -
#pragma mark ASIHTTPRequest delegate

- (void)fetchCompleted:(ASIHTTPRequest *)request
{
	NSDictionary *info = request.userInfo;
	NSString *path = [info valueForKey:@"path"];
	
	if ([path isEqualToString:@"login"]) {
		[self parseLogin:request];
	} else if ([path isEqualToString:@"register"]) {
		[self parseRegister:request];
	} else if ([path isEqualToString:@"resetPasswordWithUsername"]) {
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
	} else if ([path isEqualToString:@"user"]|| 
			   [path isEqualToString:@"updateUser"]) {
		[self parseUser:request];
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
		self.apiToken = nil;
	} else {
		[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]showErrorMsg:[request.error localizedDescription] forKey:[self notificationNameForRequest:request]];
	}
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStopLoadingForKey:[self notificationNameForRequest:request]];
}

@end
