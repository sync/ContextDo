#import "AppDelegate.h"
#import "TaskContainerViewController.h"
#import "CTXDONotificationsServices.h"
#import "FacebookServices.h"

@interface AppDelegate ()

- (void)enableGPS;
- (void)locationDidFix;
- (void)locationDidStop;
- (void)handleLocalNotification:(NSDictionary *)launchOptions;

@end


@implementation AppDelegate

SYNTHESIZE_SINGLETON_FOR_CLASS(AppDelegate)

@synthesize window, navigationController, placemark, reverseGeocoder, locationGetter, firstGPSFix, lastCurrentLocation;
@synthesize backgrounding;

#pragma mark -
#pragma mark Application lifecycle

- (void)awakeFromNib {
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	self.backgrounding = FALSE;
	
	// Override point for customization after application launch.
    
    [FacebookServices sharedFacebookServices].facebookApplicationId = FacebookApplicationId;
	
	// Add the navigation controller's view to the window and display.
    self.window.rootViewController = self.navigationController;
    [window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	self.backgrounding = TRUE;
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
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];
    
    [self enableGPS];
	self.backgrounding = FALSE;
}

- (void)enableGPS
{
	if ([CLLocationManager locationServicesEnabled]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidFix) name:GPSLocationDidFix object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidStop) name:GPSLocationDidStop object:nil];
		[self.locationGetter startUpdates];
	}
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	[self.locationGetter stopUpdates];
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
        if (reverseGeocoder) {
			[reverseGeocoder cancel];
			reverseGeocoder.delegate = nil;
			[reverseGeocoder release];
			reverseGeocoder = nil;
		}
        
		CLLocationCoordinate2D coordinate = self.currentLocation.coordinate;
		reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:coordinate];
		reverseGeocoder.delegate = self;
		[reverseGeocoder start];
	}
	
	self.lastCurrentLocation = self.currentLocation;
}

- (void)locationDidStop
{
	DLog(@"user does not want to use core location");
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
    DLog(@"reverseGeocoder failed with error:%@", [error localizedDescription]);
	[placemark release];
	placemark = nil;
	reverseGeocoder.delegate = nil;
	[reverseGeocoder release];
	reverseGeocoder = nil;
}

#pragma mark -
#pragma mark Notifications

- (void)handleLocalNotification:(NSDictionary *)launchOptions
{
	[[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];
	UILocalNotification *notification = [launchOptions valueForKey:UIApplicationLaunchOptionsLocalNotificationKey];
	if (notification) {
		[[CTXDONotificationsServices sharedCTXDONotificationsServices] parseNotification:notification];
	}
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
	[[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];
	if (notification && self.backgrounding) {
		[[CTXDONotificationsServices sharedCTXDONotificationsServices] parseNotification:notification];
	}
}

#pragma mark -
#pragma mark View Task

- (void)showTask:(Task *)task animated:(BOOL)animated
{
	// todo
}

#pragma mark -
#pragma mark View Near Tasks

- (void)showNearTasksAnimated:(BOOL)animated
{
	// todo
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

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[lastCurrentLocation release];
	[locationGetter release];
	[reverseGeocoder release];
	[placemark release];
	[navigationController release];
    [window release];
	
    [super dealloc];
}


@end

