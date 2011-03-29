#import <Foundation/Foundation.h>
#import "FBConnect.h"

#define FacebookNotification @"FacebookNotification"
#define FacebookAuthorizedPermissionsUserDefaults @"FacebookAuthorizedPermissionsUserDefaults"

@interface FacebookServices : NSObject <FBSessionDelegate, UIAlertViewDelegate> {

}

@property (nonatomic, readonly) Facebook *facebook;
@property (nonatomic, copy) NSString *facebookApplicationId;

+ (FacebookServices *)sharedFacebookServices;
- (void)authorizeForPermissions:(NSArray *)permission;

// defaults
- (BOOL)facebookAuthorizedForPermissions:(NSArray *)permissions;
- (void)setFacebookAuthorizedForPemissions:(NSArray *)permissions remove:(BOOL)remove;
- (void)removeAllFacebookAuthorizedPermissions;

@end
