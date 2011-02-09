#import <UIKit/UIKit.h>
#import <Mapkit/MapKit.h>
#import "BaseViewController.h"
#import "TaskAnnotation.h"
#import "UICGDirections.h"

@interface TaskDirectionsViewController : BaseViewController <MKMapViewDelegate, UICGDirectionsDelegate> {

}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

@property (nonatomic, retain) Task *task;
@property (nonatomic, retain) Task *currentLocationTask;

@property (nonatomic, retain) MKPolyline *routeLine;
@property (nonatomic, retain) MKPolylineView* routeLineView;
@property (nonatomic, retain) UICGDirections *directions;

- (void)refreshTask;

@property (nonatomic,  assign) UINavigationController *mainNavController;

@end
