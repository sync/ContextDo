#import "FacebookServices.h"

@implementation FacebookServices

SYNTHESIZE_SINGLETON_FOR_CLASS(FacebookServices)

@synthesize facebook, facebookApplicationId;

- (Facebook *)facebook
{
	if (!facebook) {
		facebook = [[Facebook alloc] init];
	}
	
	return facebook;
}

- (void)authorizeForPermissions:(NSArray *)permissions
{
	[self.facebook authorize:self.facebookApplicationId permissions:permissions delegate:self];
}

#pragma mark -
#pragma mark FBSessionDelegate

- (void)fbDidLoginWithPermissions:(NSArray *)permissions;
{
	DLog(@"Facebook accessToken: %@", self.facebook.accessToken);
	
	NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithBool:TRUE], @"success",
							  permissions, @"permissions",
							  nil];
	[[NSNotificationCenter defaultCenter]postNotificationName:FacebookNotification object:infoDict];
}

- (void)fbDidNotLogin:(BOOL)cancelled permissions:(NSArray *)permissions;
{
	DLog(@"Facebook did not login");
	
	NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithBool:FALSE], @"success",
							  permissions, @"permissions",
							  nil];
	[[NSNotificationCenter defaultCenter]postNotificationName:FacebookNotification object:infoDict];
}

- (void)fbDidLogout
{
	DLog(@"Facebook did logout");
	
	[self removeAllFacebookAuthorizedPermissions];
}

#pragma mark -
#pragma mark Defaults

- (BOOL)facebookAuthorizedForPermissions:(NSArray *)permissions
{
	NSArray *currentPermissions = [[NSUserDefaults standardUserDefaults]objectForKey:FacebookAuthorizedPermissionsUserDefaults];
	BOOL authorized = TRUE;
	for (NSString *permission in permissions) {
		if (![currentPermissions containsObject:permission]) {
			authorized = FALSE;
		}
	}
	return authorized;
}

- (void)setFacebookAuthorizedForPemissions:(NSArray *)permissions remove:(BOOL)remove
{
	NSMutableSet *currentPermissions = [NSMutableSet setWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:FacebookAuthorizedPermissionsUserDefaults]];
	
	for (NSString *permission in permissions) {
		if (remove) {
			[currentPermissions removeObject:permission];
		} else {
			[currentPermissions addObject:permission];
		}
	}
	
	[[NSUserDefaults standardUserDefaults]setObject:currentPermissions.allObjects forKey:FacebookAuthorizedPermissionsUserDefaults];
	[[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)removeAllFacebookAuthorizedPermissions
{
	[[NSUserDefaults standardUserDefaults]removeObjectForKey:FacebookAuthorizedPermissionsUserDefaults];
	[[NSUserDefaults standardUserDefaults]synchronize];
}

#pragma mark -
#pragma mark Deallo

- (void)dealloc {
	[facebookApplicationId release];
    [facebook release];
	
    [super dealloc];
}


@end
