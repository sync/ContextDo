#import <UIKit/UIKit.h>
#import <Mapkit/MapKit.h>
#import "BaseViewController.h"
#import "TaskAnnotation.h"
#import "UICGDirections.h"

@interface TasksMapViewController : BaseViewController <MKMapViewDelegate, UICGDirectionsDelegate, UISearchBarDelegate> {

}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet CustomSearchBar *searchBar;

@property (nonatomic, copy) NSArray *tasksSave;

@property (nonatomic, retain) NSArray *tasks;
@property (nonatomic, retain) NSArray *todayTasks;

@property (nonatomic, readonly) BOOL isTodayTasks;
@property (nonatomic, readonly) BOOL isNearTasks;

@property (nonatomic, retain) MKPolyline *routeLine;
@property (nonatomic, retain) MKPolylineView* routeLineView;
@property (nonatomic, retain) UICGDirections *directions;

@property (nonatomic,  assign) UINavigationController *mainNavController;

// Content Filtering
@property (nonatomic, retain) NSString *searchString;

@end
