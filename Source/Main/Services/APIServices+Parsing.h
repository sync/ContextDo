#import <Foundation/Foundation.h>
#import "APIServices.h"

@interface APIServices (parsing)

- (void)parseLogin:(ASIHTTPRequest *)request;
- (void)parseRegister:(ASIHTTPRequest *)request;
- (void)parseResetPassword:(ASIHTTPRequest *)request;
- (void)parseGroups:(ASIHTTPRequest *)request;

@end
