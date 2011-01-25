#import <UIKit/UIKit.h>
#import <Mapkit/MapKit.h>
#import "BaseViewController.h"
#import "TaskAnnotation.h"
#import "UICGDirections.h"
#import "UICRouteOverlayMapView.h"

@interface TaskDirectionsViewController : BaseViewController <MKMapViewDelegate, UICGDirectionsDelegate> {

}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

@property (nonatomic, retain) Task *task;
@property (nonatomic, retain) NSString *startPoint;
@property (nonatomic, retain) NSString *endPoint;

@property (nonatomic, retain) UICRouteOverlayMapView *routeOverlayView;
@property (nonatomic, retain) UICGDirections *directions;

- (void)refreshTask;

@property (nonatomic,  assign) UINavigationController *mainNavController;

@end
