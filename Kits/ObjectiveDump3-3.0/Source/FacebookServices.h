#import <Foundation/Foundation.h>
#import "FBConnect.h"

#define FacebookNotification @"FacebookNotification"
#define FacebookAuthorizedPermissionsUserDefaults @"FacebookAuthorizedPermissionsUserDefaults"

#if !defined(FacebookApplicationId)
#define FacebookApplicationId @"your_key_here"
#endif

@interface FacebookServices : NSObject <FBSessionDelegate, UIAlertViewDelegate> {

}

@property (nonatomic, readonly) Facebook *facebook;

+ (FacebookServices *)sharedFacebookServices;
- (void)authorizeForPermissions:(NSArray *)permission;

// defaults
- (BOOL)facebookAuthorizedForPermissions:(NSArray *)permissions;
- (void)setFacebookAuthorizedForPemissions:(NSArray *)permissions remove:(BOOL)remove;
- (void)removeAllFacebookAuthorizedPermissions;

@end
