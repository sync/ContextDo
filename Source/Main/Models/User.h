#import <Foundation/Foundation.h>
#import "SMModelObject.h"

@interface User : SMModelObject {

}

@property (nonatomic, retain) NSNumber *userId;
@property (nonatomic, retain) NSDictionary *settings;
@property (nonatomic, retain) NSString *facebookAccessToken;
@property (nonatomic, retain) NSNumber *hasFacebookAccessToken;

+ (User *)userWithSettings:(NSDictionary *)aSettings
	   facebookAccessToken:(NSString *)aFacebookAccessToken;

@end
