#import <Foundation/Foundation.h>
#import "OAuth.h"
#import "TwitterLoginPopupDelegate.h"
#import "TwitterLoginUiFeedback.h"
#import "CustomLoginPopup.h"

#define TwitterNotification @"TwitterDidLoginNotification"
#define TwitterAuthorizedUserDefaults @"TwitterAuthorizedUserDefaults"

@interface TwitterServices : NSObject <TwitterLoginPopupDelegate, TwitterLoginUiFeedback> {

}

@property (nonatomic, readonly) OAuth *oAuth;
@property (nonatomic, readonly) CustomLoginPopup *loginPopup;
@property (nonatomic, copy) NSString *oauthConsumerKey;
@property (nonatomic, copy) NSString *oauthConsumerSecret;

+ (TwitterServices *)sharedTwitterServices;

- (BOOL)authorizeInNavController:(UINavigationController *)navController;

// defaults
@property (nonatomic) BOOL twitterAuthorized;

@end
