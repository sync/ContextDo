#import "BaseASIServices.h"
#import "BaseASIServices+Utils.h"

@implementation BaseASIServices

@synthesize networkQueue;

- (id) init
{
	self = [super init];
	if (self != nil) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];

	}
	return self;
}

- (void)applicationWillResignActive
{
	
}


- (ASINetworkQueue *)networkQueue
{
	if (!networkQueue) {
		networkQueue = [[ASINetworkQueue alloc] init];
		if ([self respondsToSelector:@selector(fetchStarted:)]) {
			[networkQueue setRequestDidStartSelector:@selector(fetchStarted:)];
		}
		if ([self respondsToSelector:@selector(fetchCompleted:)]) {
			[networkQueue setRequestDidFinishSelector:@selector(fetchCompleted:)];
		}
		if ([self respondsToSelector:@selector(fetchFailed:)]) {
			[networkQueue setRequestDidFailSelector:@selector(fetchFailed:)];
		}
		if ([self respondsToSelector:@selector(queueFinished:)]) {
			[networkQueue setQueueDidFinishSelector:@selector(queueFinished:)];
		}
		
		[networkQueue setDelegate:self];
	}
	
	return networkQueue;
}

#pragma mark -
#pragma mark Request Constructors

- (ASIHTTPRequest *)requestWithUrl:(NSString *)url
{
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
	request.numberOfTimesToRetryOnTimeout = 1;
	request.timeOutSeconds = RequestTimeOutSeconds;
	
	request.allowCompressedResponse = TRUE;
	
	return request;
}

- (ASIFormDataRequest *)formRequestWithUrl:(NSString *)url
{
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
	request.numberOfTimesToRetryOnTimeout = 2;
	request.timeOutSeconds = RequestTimeOutSeconds;
	[request setRequestMethod:@"POST"];
	
	request.allowCompressedResponse = TRUE;
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	[request setShouldContinueWhenAppEntersBackground:YES];
#endif
	
	return request;
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

#pragma mark -
#pragma mark ASIHTTPRequest delegate

- (void)fetchStarted:(ASIHTTPRequest *)request
{	
	DLog(@"fetch started for url:%@", request.url);
}

- (void)fetchCompleted:(ASIHTTPRequest *)request
{
	NSDictionary *info = request.userInfo;
	NSString *path = [info valueForKey:@"path"];
	
	if ([path isEqualToString:@"blah"]) {
		// parseBlah
	}
	
	DLog(@"fetch completed for url:%@", request.originalURL);
}

- (void)fetchFailed:(ASIHTTPRequest *)request
{
	DLog(@"fetch failed for url:%@ error:%@", request.originalURL, [request.error localizedDescription]);
	
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]showErrorMsg:[request.error localizedDescription] forKey:[self notificationNameForRequest:request]];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStopLoadingForKey:[self notificationNameForRequest:request]];
}

- (void)queueFinished:(ASINetworkQueue *)queue
{
	DLog(@"queue finished for service:%@", NSStringFromClass([self class]));
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	
	[networkQueue release];
	
    [super dealloc];
}


@end
