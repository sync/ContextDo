#import <UIKit/UIKit.h>
#import "TaskEditViewController.h"
#import "TaskLocationDataSource.h"


@interface TaskLocationViewController : TaskEditViewController <MKMapViewDelegate> {

}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

@end
