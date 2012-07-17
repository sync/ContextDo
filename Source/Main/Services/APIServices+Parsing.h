#import <Foundation/Foundation.h>
#import "APIServices.h"


@interface APIServices (parsing)

- (void)parseResetPassword:(ASIHTTPRequest *)request;

- (void)parseGroups:(ASIHTTPRequest *)request;
- (void)parseGroup:(ASIHTTPRequest *)request;

- (void)parseTasks:(ASIHTTPRequest *)request;
- (void)parseTask:(ASIHTTPRequest *)request;

@end
