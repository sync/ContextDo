#import "APIServices.h"
#import "APIServices+Utils.h"
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
	
	request.shouldRedirect = FALSE;
	
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
	
	[request setPostValue:aUsername forKey:@"user[email]"];
	
	[self.networkQueue addOperation:request];
	[self.networkQueue go];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStartLoadingForKey:[self notificationNameForRequest:request]];
}

#pragma mark -
#pragma mark Groups

- (void)refreshGroupsWithPage:(NSInteger)page
{
	NSString *notificationName = GroupsDidLoadNotification;
	NSString *path = @"groupsWithPage";
	
	NSString *url = CTXDOURL(BASE_URL, GROUPS_PATH);
	[self downloadContentForUrl:url withObject:[NSNumber numberWithInteger:page] path:path notificationName:notificationName];
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

- (void)fetchStarted:(ASIHTTPRequest *)request
{
	DLog(@"fetch completed for url: %@", request.url);
}

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
		} else if ([path isEqualToString:@"groupsWithPage"]) {
			[self parseGroups:request];
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

- (void)queueFinished:(ASINetworkQueue *)queue
{
	DLog(@"queue finished for service: %@", NSStringFromClass([self class]));
	
}

@end
