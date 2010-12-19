#import <Foundation/Foundation.h>
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "NSDate+Extensions.h"
#import "BaseLoadingViewCenter.h"


@interface BaseServices : NSObject {
	
}

@property (nonatomic, readonly) ASINetworkQueue *networkQueue;

- (NSString *)notificationNameForRequest:(ASIHTTPRequest *)request;

- (void)informEmtpy:(BOOL)empty forKey:(NSString *)key;

@end

@protocol BaseServicesContentManagement <NSObject>

- (void)downloadContentForUrl:(NSString *)url withObject:(id)object path:(NSString *)path notificationName:(NSString *)notificationName;

- (void)fetchCompleted:(ASIHTTPRequest *)request;
- (void)fetchFailed:(ASIHTTPRequest *)request;
- (void)queueFinished:(ASINetworkQueue *)queue;

@end
