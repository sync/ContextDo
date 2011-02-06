#import <Foundation/Foundation.h>
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"

#define GoogleMapDirectionsApiNotificationDidSucceed @"GoogleMapDirectionsApiNotificationDidSucceed"
#define GoogleMapDirectionsApiNotificationDidFailed @"GoogleMapDirectionsApiNotificationDidFailed"

@interface GoogleMapApiServices : NSObject {

}

- (void)loadWithStartPoint:(NSString *)startPoint endPoint:(NSString *)endPoint options:(NSString *)options;
- (void)loadFromWaypoints:(NSArray *)waypoints options:(NSString *)options;


@end
