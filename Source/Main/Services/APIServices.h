#import <Foundation/Foundation.h>
#import "BaseServices.h"

@interface APIServices : BaseServices <BaseServicesContentManagement> {

}

+ (APIServices *)sharedAPIServices;

@property (nonatomic, assign) NSString *apiToken;
@property (nonatomic, assign) NSString *username;
@property (nonatomic, assign) NSString *password;
- (void)loginWithUsername:(NSString *)username password:(NSString *)password;
- (void)registerWithUsername:(NSString *)username password:(NSString *)password;
- (void)resetPasswordWithUsername:(NSString *)username;

- (void)refreshGroupsWithPage:(NSInteger)page;
- (void)editGroupWithName:(NSString *)name groupId:(NSNumber *)groupId;

- (void)refreshTasksWithGroupId:(NSNumber *)groupId page:(NSInteger)page;
- (void)refreshTasksWithDue:(NSString *)due page:(NSInteger)page;

@end
