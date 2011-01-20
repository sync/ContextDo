#import <Foundation/Foundation.h>
#import "BaseASIServices.h"

@interface APIServices : BaseASIServices {

}

+ (APIServices *)sharedAPIServices;

@property (nonatomic, assign) NSString *apiToken;
@property (nonatomic, assign) NSString *username;
@property (nonatomic, assign) NSString *password;
- (void)loginWithUsername:(NSString *)username password:(NSString *)password;
- (void)registerWithUsername:(NSString *)username password:(NSString *)password;
- (void)resetPasswordWithUsername:(NSString *)username;

- (void)refreshGroups;
- (void)addGroupWithName:(NSString *)name position:(NSNumber *)position;
- (void)editGroupWithId:(NSNumber *)groupId name:(NSString *)name position:(NSNumber *)position;
- (void)deleteGroupWitId:(NSNumber *)groupId;

- (void)refreshTasksWithGroupId:(NSNumber *)groupId page:(NSInteger)page;
- (void)refreshTasksWithDue:(NSString *)due page:(NSInteger)page;
- (void)refreshTasksWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude within:(CGFloat)withinInKm;
- (void)addTask:(Task *)task;
- (void)editTask:(Task *)task;
- (void)deleteTaskWitId:(NSNumber *)taskId;

@end
