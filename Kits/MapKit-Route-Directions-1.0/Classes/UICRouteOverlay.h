#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface UICRouteOverlay : NSObject {

}

+ (id)routeOverlayWithPoints:(NSArray *)points;

@property (nonatomic, retain, readonly) NSArray *points;
@property (nonatomic, retain, readonly) MKPolyline *polyline;
@property (nonatomic, readonly) MKMapRect mapRect;

@end
