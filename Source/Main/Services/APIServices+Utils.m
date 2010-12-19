#import "APIServices+Utils.h"
#import "ASIHTTPRequest.h"

@implementation APIServices (utils)

- (NSString *)authUrlWithUrl:(NSString *)url
{
	if (self.apiToken) {
		NSString *append = @"?";
		NSRange questionRange = [url rangeOfString:@"?"];
		if (questionRange.location != NSNotFound) {
			append = @"&";
		}
		url = [url stringByAppendingFormat:@"%@profile_credentials=%@", append, self.apiToken];
	}
	
	return url;
}

- (ASIHTTPRequest *)requestWithUrl:(NSString *)url
{
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
	request.numberOfTimesToRetryOnTimeout = 1;
	request.timeOutSeconds = RequestTimeOutSeconds;
	[request addRequestHeader:@"Accept" value:@"application/json"];
	
	return request;
}

- (ASIFormDataRequest *)formRequestWithUrl:(NSString *)url
{
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
	request.numberOfTimesToRetryOnTimeout = 2;
	request.timeOutSeconds = RequestTimeOutSeconds;
	[request setRequestMethod:@"POST"];
	
	[request setShouldAttemptPersistentConnection:NO];
	[request addRequestHeader:@"X-Requested-With" value:@"XMLHttpRequest"];
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	[request setShouldContinueWhenAppEntersBackground:YES];
#endif
	
	return request;
}

- (void)notifyDone:(ASIHTTPRequest *)request object:(id)object;
{
	[[NSNotificationCenter defaultCenter] postNotificationName:[self notificationNameForRequest:request] object:object];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStopLoadingForKey:[self notificationNameForRequest:request]];
}

- (void)notifyFailed:(ASIHTTPRequest *)request withError:(NSString *)errorString
{
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]showErrorMsg:errorString forKey:[self notificationNameForRequest:request]];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStopLoadingForKey:[self notificationNameForRequest:request]];
}

@end
