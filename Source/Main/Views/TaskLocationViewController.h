#import <UIKit/UIKit.h>
#import "TaskEditViewController.h"
#import "TaskLocationDataSource.h"


@interface TaskLocationViewController : TaskEditViewController <MKMapViewDelegate> {

}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

@property (nonatomic, readonly) CLPlacemark *placemark;
@property (nonatomic, readonly) CLGeocoder *reverseGeocoder;

@property (nonatomic, retain) CLLocation *lastCenterLocation;

@property (nonatomic) BOOL userEdited;

@end
