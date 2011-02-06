#import <Foundation/Foundation.h>
#import "UICGStep.h"

@interface UICGLeg : NSObject {

}

@property (nonatomic, retain, readonly) NSArray *steps;
@property (nonatomic, retain, readonly) NSDictionary *duration;
@property (nonatomic, retain, readonly) NSDictionary *distance;
@property (nonatomic, retain, readonly) CLLocation *startLocation;
@property (nonatomic, retain, readonly) CLLocation *endLocation;
@property (nonatomic, retain, readonly) NSString *startAddress;
@property (nonatomic, retain, readonly) NSString *endAddress;
@property (nonatomic, retain, readonly) NSArray *viaWaypoint;

@property (nonatomic, readonly) NSInteger numerOfSteps;
- (UICGStep *)stepAtIndex:(NSInteger)index;

+ (UICGLeg *)legWithDictionaryRepresentation:(NSDictionary *)dictionary;
- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary;

@end
