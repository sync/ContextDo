#import <Foundation/Foundation.h>
#import "OAuth.h"
#import "TwitterLoginPopupDelegate.h"
#import "TwitterLoginUiFeedback.h"
#import "CustomLoginPopup.h"

#define TwitterNotification @"TwitterDidLoginNotification"
#define TwitterAuthorizedUserDefaults @"TwitterAuthorizedUserDefaults"

#if !defined(OAUTH_CONSUMER_KEY)
#define OAUTH_CONSUMER_KEY @"your_key_here"
#endif

#if !defined(OAUTH_CONSUMER_SECRET)
#define OAUTH_CONSUMER_SECRET @"your_secret_here"
#endif

@interface TwitterServices : NSObject <TwitterLoginPopupDelegate, TwitterLoginUiFeedback> {

}

@property (nonatomic, readonly) OAuth *oAuth;
@property (nonatomic, readonly) CustomLoginPopup *loginPopup;

+ (TwitterServices *)sharedTwitterServices;

- (BOOL)authorizeInNavController:(UINavigationController *)navController;

// defaults
@property (nonatomic) BOOL twitterAuthorized;

@end
