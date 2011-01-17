#import "AppDelegate.h"
#import "LoginViewController.h"

@interface AppDelegate (private)

- (void)refreshAllControllers;
- (void)enableGPS;
- (void)locationDidFix;
- (void)locationDidStop;
- (void)logout:(BOOL)showingLogin animated:(BOOL)animated;

@end


@implementation AppDelegate

SYNTHESIZE_SINGLETON_FOR_CLASS(AppDelegate)

@synthesize window, navigationController, placemark, reverseGeocoder, locationGetter, firstGPSFix;

#pragma mark -
#pragma mark Application lifecycle

- (UINavigationController *)loginNavigationController
{
	LoginViewController *controller = [[[LoginViewController alloc]initWithNibName:@"LoginView" bundle:nil]autorelease];
	CustomNavigationController *navController = [[[CustomNavigationController alloc]initWithRootViewController:controller]autorelease];
	[navController.customNavigationBar setBackgroundImage:[DefaultStyleSheet sharedDefaultStyleSheet].navBarBackgroundImage
											  forBarStyle:UIBarStyleDefault];
	
	return navController;
}

- (void)awakeFromNib {
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSNumber numberWithBool:FALSE], ShouldResetCredentialsAtStartup,
															 nil]];
	
	// Add the navigation controller's view to the window and display.
    [window addSubview:self.navigationController.view];
    [window makeKeyAndVisible];
	
	[self.navigationController.customNavigationBar setBackgroundImage:[DefaultStyleSheet sharedDefaultStyleSheet].navBarBackgroundImage
														  forBarStyle:UIBarStyleDefault];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	[self.locationGetter stopUpdates];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	[[NSUserDefaults standardUserDefaults]synchronize];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	if ([userDefaults boolForKey:ShouldResetCredentialsAtStartup]) {
		// clear all request previous credentials
		[self logout:FALSE animated:FALSE];
		// set it back to it's default value
		[userDefaults setBool:FALSE forKey:ShouldResetCredentialsAtStartup];
		[[NSUserDefaults standardUserDefaults]synchronize];
	}
	
	
	NSString *apiToken = [APIServices sharedAPIServices].apiToken;
	if (apiToken.length == 0) {
		if ([APIServices sharedAPIServices].username.length > 0 && [APIServices sharedAPIServices].password.length > 0) {
			[[APIServices sharedAPIServices]loginWithUsername:[APIServices sharedAPIServices].username password:[APIServices sharedAPIServices].password];
		} else {
			[self showLoginView:FALSE];
		}
	} else {
		[self refreshAllControllers];
	}
}

- (void)enableGPS
{
	if ([self.locationGetter.locationManager locationServicesEnabled]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidFix) name:GPSLocationDidFix object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidStop) name:GPSLocationDidStop object:nil];
		[self.locationGetter startUpdates];
	}
}

- (void)refreshAllControllers
{
	[self enableGPS];
	[[APIServices sharedAPIServices]refreshGroupsWithPage:1];
}

- (void)logout:(BOOL)showingLogin animated:(BOOL)animated
{
	// clear apiKey
	[APIServices sharedAPIServices].apiToken = nil;
	// clear username / password
	[APIServices sharedAPIServices].username = nil;
	[APIServices sharedAPIServices].password = nil;
	// clear all sessions + cookies
	[ASIHTTPRequest clearSession];
	// go back to user login
	if (showingLogin) {
		[[AppDelegate sharedAppDelegate]showLoginView:animated];
	}
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	[self.locationGetter stopUpdates];
}

#pragma mark -
#pragma mark Login

- (void)hideLoginView:(BOOL)animated
{
	[self.navigationController dismissModalViewControllerAnimated:animated];
	[self refreshAllControllers];
}

- (void)showLoginView:(BOOL)animated
{
	[self.navigationController presentModalViewController:self.loginNavigationController animated:animated];
}

#pragma mark -
#pragma mark Geolocation:

- (MyLocationGetter *)locationGetter
{
	if (!locationGetter) {
		locationGetter = [[MyLocationGetter alloc]init];
	}
	return locationGetter;
}

- (CLLocation *)currentLocation
{
	return [self.locationGetter.locationManager location];
}

- (void)locationDidFix
{
	DLog(@"user got a fix with core location");
	
	if (self.hasValidCurrentLocation) {
		CLLocationCoordinate2D coordinate = self.currentLocation.coordinate;
		
		if (reverseGeocoder) {
			[reverseGeocoder cancel];
			reverseGeocoder.delegate = nil;
			[reverseGeocoder release];
			reverseGeocoder = nil;
		}
		reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:coordinate];
		reverseGeocoder.delegate = self;
		[reverseGeocoder start];
	}
}

- (void)locationDidStop
{
	NSLog(@"user does not want to use core location");
}

- (BOOL)hasValidCurrentLocation
{
	return (self.currentLocation && CLLocationCoordinate2DIsValid(self.currentLocation.coordinate));
}

#pragma mark -
#pragma mark MKReverseGeocoderDelegate methods

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)newPlacemark 
{
    placemark = [newPlacemark retain];
    reverseGeocoder.delegate = nil;
	[reverseGeocoder release];
	reverseGeocoder = nil;
	[[NSNotificationCenter defaultCenter] postNotificationName:PlacemarkDidChangeNotification object:nil userInfo:nil];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error 
{
    [placemark release];
	placemark = nil;
	reverseGeocoder.delegate = nil;
	[reverseGeocoder release];
	reverseGeocoder = nil;
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[locationGetter release];
	[reverseGeocoder release];
	[placemark release];
	[navigationController release];
    [window release];
	
    [super dealloc];
}


@end

