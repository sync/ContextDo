#import "BaseASIServices+Utils.h"

@implementation BaseASIServices (utils)

#pragma mark -
#pragma mark Request Status

#define BaseServicesNotificationUnknown @"BaseServicesNotificationUnknown"

- (NSString *)notificationNameForRequest:(ASIHTTPRequest *)request
{
	NSString *notificationName = [request.userInfo valueForKey:@"notificationName"];
	return (notificationName) ? notificationName : BaseServicesNotificationUnknown;
}

- (void)informEmtpy:(BOOL)empty forKey:(NSString *)key
{
	// TODO on main thread
	if (empty) {
		[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]showErrorMsg:@"Empty Content!" forKey:key];
	} else {
		[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeErrorMsgForKey:key];
	}
}

- (void)notifyDoneForKey:(NSString *)key withObject:(id)object
{
	[[NSNotificationCenter defaultCenter] postNotificationName:key object:object];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStopLoadingForKey:key];
}

- (void)notifyDone:(ASIHTTPRequest *)request withObject:(id)object;
{
	dispatch_async(dispatch_get_main_queue(), ^{
        [self notifyDoneForKey:[self notificationNameForRequest:request] withObject:object];
    });
}

- (void)notifyFailedForKey:(NSString *)key withError:(NSString *)errorString
{
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]showErrorMsg:errorString forKey:key];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]didStopLoadingForKey:key];
}

- (void)notifyFailed:(ASIHTTPRequest *)request withError:(NSString *)errorString
{
	dispatch_async(dispatch_get_main_queue(), ^{
        [self notifyFailedForKey:[self notificationNameForRequest:request] withError:errorString];
    });
}

@end
