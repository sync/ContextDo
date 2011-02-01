#import "User.h"


@implementation User

@synthesize settings, facebookAccessToken, hasFacebookAccessToken, userId;

+ (User *)userWithSettings:(NSDictionary *)aSettings
	   facebookAccessToken:(NSString *)aFacebookAccessToken
{
	User *user = [[[User alloc]init]autorelease];
	user.settings = aSettings;
	user.facebookAccessToken = aFacebookAccessToken;
	
	return user;
}

@end
