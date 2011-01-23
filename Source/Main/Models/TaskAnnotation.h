#import <Foundation/Foundation.h>

@interface TaskAnnotation : NSObject <MKAnnotation> {
}

@property (nonatomic, retain) Task *task;
@property (nonatomic) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate;

@end
