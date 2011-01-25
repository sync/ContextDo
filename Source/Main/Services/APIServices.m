#import "APIServices.h"
#import "BaseASIServices+Utils.h"
#import "APIServices+Parsing.h"

@implementation APIServices

SYNTHESIZE_SINGLETON_FOR_CLASS(APIServices)

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
	
	[request addRequestHeader:@"Accept" value:@"application/json"];
	
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
	
	[request addRequestHeader:@"Accept" value:@"application/json"];
	
	[request setPostValue:aUsername forKey:@"user[email]"];
	[request setPostValue:aPassword forKey:@"user[password]"];
	[request setPostValue:aPassword forKey:@"user[password_confirmation]"];
	
	
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
	
	[request addRequestHeader:@"Accept" value:@"application/json"];
	
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

- (void)addGroupWithName:(NSString *)name position:(NSNumber *)position
{
	if (!name) {
		return;
	}
	
	NSString *notificationName = GroupAddNotification;
	NSString *path = @"addGroupWithName";
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  path, @"path",
							  notificationName, @"notificationName",
							  name, @"name",
							  position, @"position",
							  nil];
	
	NSString *url = CTXDOURL(BASE_URL, GROUPS_PATH);
	ASIFormDataRequest *request = [self formRequestWithUrl:url];	
	request.userInfo = userInfo;
	request.delegate = self;
	
	[request addRequestHeader:@"Accept" value:@"application/json"];
	
	[request setPostValue:name forKey:@"group[name]"];
	if (position) {
		[request setPostValue:position forKey:@"group[position]"];
	}
	
	[self.networkQueue addOperation:request];
	[self.networkQueue go];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStartLoadingForKey:[self notificationNameForRequest:request]];
}


- (void)updateGroupWithId:(NSNumber *)groupId name:(NSString *)name position:(NSNumber *)position
{
	if (!name) {
		return;
	}
	
	NSString *notificationName = GroupEditNotification;
	NSString *path = @"editGroupWithId";
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  path, @"path",
							  notificationName, @"notificationName",
							  nil];
	
	NSString *url = GROUPURL(BASE_URL, GROUPS_PATH, groupId);
	ASIFormDataRequest *request = [self formRequestWithUrl:url];	
	request.userInfo = userInfo;
	request.delegate = self;
	
	[request addRequestHeader:@"Accept" value:@"application/json"];
	
	[request setRequestMethod:@"PUT"];

	[request setPostValue:name forKey:@"group[name]"];
	if (position) {
		[request setPostValue:position forKey:@"group[position]"];
	}
	
	[self.networkQueue addOperation:request];
	[self.networkQueue go];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStartLoadingForKey:[self notificationNameForRequest:request]];
}

- (void)deleteGroupWitId:(NSNumber *)groupId
{
	if (!groupId) {
		return;
	}
	
	NSString *notificationName = GroupDeleteNotification;
	NSString *path = @"deleteGroupWitId";
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  path, @"path",
							  notificationName, @"notificationName",
							  groupId, @"object",
							  nil];
	
	NSString *url = GROUPURL(BASE_URL, GROUPS_PATH, groupId);
	ASIFormDataRequest *request = [self formRequestWithUrl:url];	
	request.userInfo = userInfo;
	request.delegate = self;
	
	[request addRequestHeader:@"Accept" value:@"application/json"];
	
	[request setRequestMethod:@"DELETE"];
	
	[self.networkQueue addOperation:request];
	[self.networkQueue go];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStartLoadingForKey:[self notificationNameForRequest:request]];
}

#pragma mark -
#pragma mark Tasks

- (void)refreshTasksWithGroupId:(NSNumber *)groupId
{
	NSString *notificationName = TasksDidLoadNotification;
	NSString *path = @"tasksWithGroupId";
	
	NSString *url = TASKSURL(BASE_URL, TASKS_PATH, groupId);
	[self downloadContentForUrl:url withObject:nil path:path notificationName:notificationName];
}

- (void)refreshTasksWithDue:(NSString *)due
{
	NSString *notificationName = TasksDueDidLoadNotification;
	NSString *path = @"tasksWithDue";
	
	NSString *url = TASKSDUEURL(BASE_URL, TASKS_PATH, due);
	[self downloadContentForUrl:url withObject:nil path:path notificationName:notificationName];
}

- (void)refreshTasksWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude within:(CGFloat)withinInKm
{
	NSString *notificationName = TasksWithinDidLoadNotification;
	NSString *path = @"tasksWithLatitude";
	
	NSString *url = TASKSWITHINURL(BASE_URL, TASKS_PATH, latitude, longitude, withinInKm);
	[self downloadContentForUrl:url withObject:nil path:path notificationName:notificationName];
}

- (void)refreshTasksWithQuery:(NSString *)query;
{
	NSString *notificationName = TasksSearchDidLoadNotification;
	NSString *path = @"tasksWithQuery";
	
	NSString *url = TASKSSEARCHURL(BASE_URL, TASKS_PATH, query);
	[self downloadContentForUrl:url withObject:nil path:path notificationName:notificationName];
}

- (void)refreshTasksEdited
{
	NSString *notificationName = TasksWithinDidLoadNotification;
	NSString *path = @"editedTasks";
	
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc]init]autorelease];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	NSString *updatedSince = [dateFormatter stringFromDate:[NSDate date]];
	NSString *url = TASKSUPDATEDSINCEURL(BASE_URL, TASKS_PATH, updatedSince);
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
	
	[request addRequestHeader:@"Content-Type" value:@"application/json"];
	[request addRequestHeader:@"Accept" value:@"application/json"];
	
	NSArray *excluding = [NSArray arrayWithObjects:
						  @"groupName",
						  @"taskId",
						  @"groupId",
						  @"updatedAt",
						  @"createdAt",
						  @"formattedContact",
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
	NSString *path = @"editTask";
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  path, @"path",
							  notificationName, @"notificationName",
							  task, @"object",
							  nil];
	
	NSString *url = TASKURL(BASE_URL, GROUPS_PATH, task.groupId, task.taskId);
	ASIFormDataRequest *request = [self formRequestWithUrl:url];	
	request.userInfo = userInfo;
	request.delegate = self;
	
	[request addRequestHeader:@"Content-Type" value:@"application/json"];
	[request addRequestHeader:@"Accept" value:@"application/json"];
	
	[request setRequestMethod:@"PUT"];
	
	NSArray *excluding = [NSArray arrayWithObjects:
						  @"groupName",
						  @"taskId",
						  @"groupId",
						  @"updatedAt",
						  @"createdAt",
						  @"formattedContact",
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
	
	[request addRequestHeader:@"Accept" value:@"application/json"];
	
	[request setRequestMethod:@"DELETE"];
	
	[self.networkQueue addOperation:request];
	[self.networkQueue go];
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
	
	[request addRequestHeader:@"Accept" value:@"application/json"];
	
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
	NSError *error = request.error;
	if (error) {
		DLog(@"wserror: %@", error);
		[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]showErrorMsg:[error localizedDescription] forKey:[self notificationNameForRequest:request]];
	} else {
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
				   [path isEqualToString:@"editedTasks"]) {
			[self parseTasks:request];
		} else if ([path isEqualToString:@"addGroupWithName"]|| 
				   [path isEqualToString:@"editGroupWithId"] ||
				   [path isEqualToString:@"deleteGroupWitId"]) {
			[self parseGroup:request];
		} else if ([path isEqualToString:@"addTask"]|| 
				   [path isEqualToString:@"editTask"] ||
				   [path isEqualToString:@"deleteTaskWitId"]) {
			[self parseTask:request];
		}
	}
	
	DLog(@"fetch completed for url: %@ error:%@", request.originalURL, [request.error localizedDescription]);
}

- (void)fetchFailed:(ASIHTTPRequest *)request
{
	DLog(@"fetch failed for url: %@ error:%@", request.originalURL, [request.error localizedDescription]);
	
	if ([request responseStatusCode] == 401) {
		if ([request.url.absoluteString hasSuffix:LOGIN_PATH]) {
			[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]showErrorMsg:@"Wrong Username or Password!" forKey:[self notificationNameForRequest:request]];
		} else {
			[[AppDelegate sharedAppDelegate]showLoginView:TRUE];
		}
	} else {
		[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]showErrorMsg:[request.error localizedDescription] forKey:[self notificationNameForRequest:request]];
	}
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStopLoadingForKey:[self notificationNameForRequest:request]];
}

@end
