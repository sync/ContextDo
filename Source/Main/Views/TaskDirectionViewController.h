#import <Foundation/Foundation.h>
#import <Mapkit/MapKit.h>
#import "BaseViewController.h"
#import "TaskAnnotation.h"

@interface TaskDirectionsViewController : BaseViewController {

}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

@property (nonatomic, retain) Task *task;
@property (nonatomic, retain) TaskAnnotation *currentAnnotation;

@end
