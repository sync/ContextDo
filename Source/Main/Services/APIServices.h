#import <Foundation/Foundation.h>
#import "BaseASIServices.h"

@interface APIServices : BaseASIServices {

}

+ (APIServices *)sharedAPIServices;

@property (nonatomic, retain) ASINetworkQueue *serialNetworkQueue;
- (void)downloadSeriallyContentForUrl:(NSString *)url withObject:(id)object path:(NSString *)path notificationName:(NSString *)notificationName;

- (void)refreshGroups;
- (void)refreshGroups;
- (void)addGroup:(Group *)group;
- (void)updateGroup:(Group *)group;
- (void)deleteGroup:(Group *)group;
- (void)syncGroups;

- (void)refreshTasksWithGroupId:(NSNumber *)groupId;
- (void)refreshTasksWithDue:(NSString *)due;
- (void)refreshTasksDueToday;
- (void)refreshTasksWithLatitude:(CLLocationDegrees)latitude
					   longitude:(CLLocationDegrees)longitude;
- (void)refreshTasksWithQuery:(NSString *)query;
- (void)refreshTasksEdited;
- (void)addTask:(Task *)task;
- (void)updateTask:(Task *)task;
- (void)deleteTask:(Task *)task;

@property (nonatomic, assign) NSNumber *alertsDistanceWithin;
- (CGFloat)alertsDistancKmToSliderValue:(CGFloat)value;
- (CGFloat)sliderValueToAlertsDistancKm:(CGFloat)value;

@end
