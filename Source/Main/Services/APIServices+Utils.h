#import <Foundation/Foundation.h>


@interface APIServices (utils)

- (NSString *)authUrlWithUrl:(NSString *)url;
- (ASIHTTPRequest *)requestWithUrl:(NSString *)url;
- (ASIFormDataRequest *)formRequestWithUrl:(NSString *)url;

- (void)notifyDone:(ASIHTTPRequest *)request object:(id)object;
- (void)notifyFailed:(ASIHTTPRequest *)request withError:(NSString *)errorString;

@end
