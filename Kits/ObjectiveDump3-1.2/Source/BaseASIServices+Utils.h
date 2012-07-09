#import <Foundation/Foundation.h>
#import "BaseASIServices.h"

@interface BaseASIServices (utils)

- (NSString *)notificationNameForRequest:(ASIHTTPRequest *)request;
- (void)informEmtpy:(BOOL)empty forKey:(NSString *)key;
- (void)notifyDone:(ASIHTTPRequest *)request withObject:(id)object;
- (void)notifyDoneForKey:(NSString *)key withObject:(id)object;
- (void)notifyFailed:(ASIHTTPRequest *)request withError:(NSString *)errorString;
- (void)notifyFailedForKey:(NSString *)key withError:(NSString *)errorString;

@end
