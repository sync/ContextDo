#import <Foundation/Foundation.h>
#import "BaseASIServices.h"

@interface BaseASIServices (utils)

- (NSString *)notificationNameForRequest:(ASIHTTPRequest *)request;
- (void)informEmtpy:(BOOL)empty forKey:(NSString *)key;
- (void)notifyDone:(ASIHTTPRequest *)request object:(id)object;
- (void)notifyFailed:(ASIHTTPRequest *)request withError:(NSString *)errorString;

@end
