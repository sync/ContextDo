#import "BaseServices.h"

@implementation BaseServices

@synthesize networkQueue;

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

- (void)informEmtpy:(BOOL)empty forKey:(NSString *)key
{
	if (empty) {
		[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]showErrorMsg:@"Empty Content!" forKey:key];
	} else {
		[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeErrorMsgForKey:key];
	}
}

#define BaseServicesNotificationUnknown @"BaseServicesNotificationUnknown"

- (NSString *)notificationNameForRequest:(ASIHTTPRequest *)request
{
	NSString *notificationName = [request.userInfo valueForKey:@"notificationName"];
	return (notificationName) ? notificationName : BaseServicesNotificationUnknown;
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	[networkQueue release];
	
    [super dealloc];
}


@end
