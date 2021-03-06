#import "AppDelegate.h"
#import "LoginViewController.h"
#import "TaskContainerViewController.h"
#import "TasksContainerViewController.h"
#import "CTXDONotificationsServices.h"
#import "FacebookServices.h"
#import <Parse/Parse.h>
#import "PFUser+CTXDO.h"

@interface AppDelegate ()

- (void)enableGPS;
- (void)locationDidFix;
- (void)locationDidStop;
- (void)handleLocalNotification:(NSDictionary *)launchOptions;

@end


@implementation AppDelegate

SYNTHESIZE_SINGLETON_FOR_CLASS(AppDelegate)

@synthesize window, navigationController, reverseGeocoder, placemark, locationGetter, firstGPSFix, blackedOutView, lastCurrentLocation;
@synthesize backgrounding;

#pragma mark -
#pragma mark Application lifecycle

- (UINavigationController *)loginNavigationController
{
	LoginViewController *controller = [[[LoginViewController alloc]initWithNibName:@"LoginView" bundle:nil]autorelease];
	CustomNavigationController *navController = [[DefaultStyleSheet sharedDefaultStyleSheet]customNavigationControllerWithRoot:controller];
	
	return navController;
}

- (void)awakeFromNib {
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	self.backgrounding = FALSE;
    
    // Setup HockeyKit
    [[BWHockeyManager sharedHockeyManager] setAppIdentifier:@"0cd352d4bb42e74001d69675a1337a31"];
    [[BWHockeyManager sharedHockeyManager] setDelegate:self];
    
    // Setup QuincyKit
    [[BWQuincyManager sharedQuincyManager] setAppIdentifier:@"0cd352d4bb42e74001d69675a1337a31"];
    
    // Setup Parse
    [Parse setApplicationId:@"0rA5BgKOKUwhSdspvhywcS0GA6Dy4DXmJLUdHX2E"
                  clientKey:@"t7HxxxdlUSgh6dLGrKxP3amfYDGmHKztcdSjipKH"];
    [PFACL setDefaultACL:[PFACL ACL] withAccessForCurrentUser:YES];
    
    // Setup Facebook
    [FacebookServices sharedFacebookServices].facebookApplicationId = FacebookApplicationId;
	
	// Add the navigation controller's view to the window and display.
    [window addSubview:self.navigationController.view];
    [window makeKeyAndVisible];
	
	[self.navigationController.customNavigationBar setBackgroundImage:[DefaultStyleSheet sharedDefaultStyleSheet].navBarBackgroundImage
														  forBarStyle:UIBarStyleBlackOpaque];
	[self.navigationController.customToolbar setBackgroundImage:[DefaultStyleSheet sharedDefaultStyleSheet].toolbarBackgroundImage
													forBarStyle:UIBarStyleBlackOpaque];
	[self.navigationController.customToolbar setShadowImage:[DefaultStyleSheet sharedDefaultStyleSheet].toolbarShadowImage
												forBarStyle:UIBarStyleBlackOpaque];
	
	PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        [self handleLocalNotification:launchOptions];
    }
	
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
    
	// todo perhpas refresh user
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser) {
		[self showLoginView:FALSE];
	} else {
		[self enableGPS];
		[[CTXDONotificationsServices sharedCTXDONotificationsServices]refreshTasksForLocalNotification];
	}
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

- (void)logout:(BOOL)showingLogin animated:(BOOL)animated
{
	// clear user
    [PFUser logOut];
	// clear all sessions + cookies
	[ASIHTTPRequest clearSession];
	// go back to user login
	if (showingLogin) {
		[[AppDelegate sharedAppDelegate]showLoginView:animated];
	}
	[self.navigationController popToRootViewControllerAnimated:TRUE];
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	[self.locationGetter stopUpdates];
}

#pragma mark -
#pragma mark Hockey

- (NSString *)customDeviceIdentifier {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)]) {
        return [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
    }
    
    return nil;
}

#pragma mark -
#pragma mark Login

- (void)hideLoginView:(BOOL)animated
{
	[self.navigationController dismissModalViewControllerAnimated:animated];
	
	[self enableGPS];
	[[CTXDONotificationsServices sharedCTXDONotificationsServices]refreshTasksForLocalNotification];
	[[APIServices sharedAPIServices]refreshGroups];
}

- (void)showLoginView:(BOOL)animated
{
	[self.navigationController presentModalViewController:self.loginNavigationController animated:animated];
}

#pragma mark -
#pragma mark Blackout Main View

- (BOOL)isBlackingOutTopViewElements
{
	return (self.blackedOutView != nil);
}

- (void)blackOutTopViewElementsAnimated:(BOOL)animated
{
	if (self.isBlackingOutTopViewElements) {
		return;
	}
	
	CGSize boundsSize = self.window.bounds.size;
	self.blackedOutView = [[[UIView alloc]initWithFrame:CGRectMake(0.0, 
																   -(20 + 44),
																   boundsSize.width,
																   20 + 44)]autorelease];
	self.blackedOutView.backgroundColor = [DefaultStyleSheet sharedDefaultStyleSheet].blackedOutColor;
	[self.window addSubview:self.blackedOutView];
	
	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.1];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	}
	
	self.blackedOutView.frame = CGRectMake(0.0, 
										   0.0,
										   boundsSize.width,
										   self.blackedOutView.frame.size.height);
	
	if (animated) {
		[UIView commitAnimations];
	}
}

- (void)hideBlackOutTopViewElementsAnimated:(BOOL)animated
{
	if (!self.isBlackingOutTopViewElements) {
		return;
	}
	
	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDelay:0.28];
		[UIView setAnimationDuration:0.09];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(hideBlackoutAnimationDidStop)];
	}
	
	CGSize boundsSize = self.window.bounds.size;
	self.blackedOutView.frame = CGRectMake(0.0, 
										   -self.blackedOutView.frame.size.height,
										   boundsSize.width,
										   self.blackedOutView.frame.size.height);
	
	if (animated) {
		[UIView commitAnimations];
	}
}

- (void)hideBlackoutAnimationDidStop
{
	[self.blackedOutView removeFromSuperview];
	blackedOutView = nil;
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
		
		CGFloat distance = [PFUser currentUser].alertsDistanceWithin * 1000;
		if (!self.lastCurrentLocation || [self.currentLocation distanceFromLocation:self.lastCurrentLocation] >= distance) {
			[[APIServices sharedAPIServices]refreshTasksWithLatitude:coordinate.latitude longitude:coordinate.longitude];
		}
        
        if (reverseGeocoder) {
            [reverseGeocoder cancelGeocode];
            [reverseGeocoder release];
            reverseGeocoder = nil;
        }
        reverseGeocoder = [[CLGeocoder alloc] init];
        [reverseGeocoder reverseGeocodeLocation:self.currentLocation 
                              completionHandler:^(NSArray* placemarks, NSError* error) {
                                  if (error || placemarks.count == 0) {
                                      [placemark release];
                                      placemark = nil;
                                      return;
                                  }
                                  
                                  placemark = [[placemarks objectAtIndex:0] retain];
                                  [[NSNotificationCenter defaultCenter] postNotificationName:PlacemarkDidChangeNotification object:nil userInfo:nil];
                              }];
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
	[[NSNotificationCenter defaultCenter]postNotificationName:GroupShouldDismissInfo object:nil];
	
	TaskContainerViewController *controller = [[[TaskContainerViewController alloc]initWithNibName:@"TaskContainerView" bundle:nil]autorelease];
	controller.task = task;
	controller.tasks = [NSArray arrayWithObject:task];
	controller.showCloseButton = TRUE;
	CustomNavigationController *navController = [[DefaultStyleSheet sharedDefaultStyleSheet]customNavigationControllerWithRoot:controller];
	[self.navigationController presentModalViewController:navController animated:TRUE];
}

#pragma mark -
#pragma mark View Near Tasks

- (void)showNearTasksAnimated:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter]postNotificationName:GroupShouldDismissInfo object:nil];
	
	Group *nearGroup = [Group groupWithId:[NSNumber numberWithInt:NSNotFound]
									 name:NearTasksPlacholder];
	
	TasksContainerViewController *controller = [[[TasksContainerViewController alloc]initWithNibName:@"TasksContainerView" bundle:nil]autorelease];
	controller.group = nearGroup;
	controller.showCloseButton = TRUE;
	CustomNavigationController *navController = [[DefaultStyleSheet sharedDefaultStyleSheet]customNavigationControllerWithRoot:controller];
	[self.navigationController presentModalViewController:navController animated:TRUE];
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

