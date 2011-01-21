#import <UIKit/UIKit.h>
#import "TaskEditViewController.h"
#import "TaskLocationDataSource.h"


@interface TaskLocationViewController : TaskEditViewController <MKMapViewDelegate, MKReverseGeocoderDelegate> {

}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

@property (nonatomic, readonly) MKPlacemark *placemark;
@property (nonatomic, readonly) MKReverseGeocoder *reverseGeocoder;

@property (nonatomic, retain) CLLocation *lastCenterLocation;

@property (nonatomic) BOOL userEdited;

@end
