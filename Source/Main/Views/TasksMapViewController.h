#import <UIKit/UIKit.h>
#import <Mapkit/MapKit.h>
#import "BaseViewController.h"
#import "TaskAnnotation.h"
#import "UICGDirections.h"
#import "UICRouteOverlayMapView.h"

@interface TasksMapViewController : BaseViewController <MKMapViewDelegate, UICGDirectionsDelegate, UISearchBarDelegate> {

}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet CustomSearchBar *customSearchBar;

@property (nonatomic, retain) Group *group;
@property (nonatomic, retain) NSArray *tasks;

@property (nonatomic, readonly) BOOL isTodayTasks;
@property (nonatomic, readonly) NSString *nowDue;

@property (nonatomic, retain) UICRouteOverlayMapView *routeOverlayView;
@property (nonatomic, retain) UICGDirections *directions;

@property (nonatomic,  assign) UINavigationController *mainNavController;

- (void)refreshTasksDirection;

@end