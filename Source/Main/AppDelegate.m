#import "AppDelegate.h"
#import "LoginViewController.h"
#import "TaskContainerViewController.h"
#import "TasksContainerViewController.h"

@interface AppDelegate (private)

- (void)refreshAllControllers;
- (void)enableGPS;
- (void)locationDidFix;
- (void)locationDidStop;
- (void)logout:(BOOL)showingLogin animated:(BOOL)animated;
- (void)handleLocalNotification:(NSDictionary *)launchOptions;
- (NSDictionary *)userInfoForTask:(Task *)task today:(BOOL)today;
- (UILocalNotification *)hasLocalNotificationForTaskId:(NSNumber *)taskId today:(BOOL)today;
- (void)refreshTasksForLocalNotification;
- (Task *)taskForUserInfo:(NSDictionary *)userInfo;
- (void)parseNotification:(UILocalNotification *)notification;
- (void)showTask:(Task *)task animated:(BOOL)animated;
- (void)showNearTasksAnimated:(BOOL)animated;

@end


@implementation AppDelegate

SYNTHESIZE_SINGLETON_FOR_CLASS(AppDelegate)

@synthesize window, navigationController, placemark, reverseGeocoder, locationGetter, firstGPSFix, blackedOutView, lastCurrentLocation;

#pragma mark -
#pragma mark Application lifecycle

- (UINavigationController *)loginNavigationController
{
	LoginViewController *controller = [[[LoginViewController alloc]initWithNibName:@"LoginView" bundle:nil]autorelease];
	CustomNavigationController *navController = [[[CustomNavigationController alloc]initWithRootViewController:controller]autorelease];
	navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	[navController.customNavigationBar setBackgroundImage:[DefaultStyleSheet sharedDefaultStyleSheet].navBarBackgroundImage
														  forBarStyle:UIBarStyleBlackOpaque];
	[navController.customToolbar setBackgroundImage:[DefaultStyleSheet sharedDefaultStyleSheet].toolbarBackgroundImage
													forBarStyle:UIBarStyleBlackOpaque];
	[navController.customToolbar setShadowImage:[DefaultStyleSheet sharedDefaultStyleSheet].toolbarShadowImage
												forBarStyle:UIBarStyleBlackOpaque];
	
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
														  forBarStyle:UIBarStyleBlackOpaque];
	[self.navigationController.customToolbar setBackgroundImage:[DefaultStyleSheet sharedDefaultStyleSheet].toolbarBackgroundImage
													forBarStyle:UIBarStyleBlackOpaque];
	[self.navigationController.customToolbar setShadowImage:[DefaultStyleSheet sharedDefaultStyleSheet].toolbarShadowImage
												forBarStyle:UIBarStyleBlackOpaque];
	
	[self handleLocalNotification:launchOptions];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTasksForLocalNotification) name:TaskEditNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTasksForLocalNotification) name:TaskAddNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldCheckTodayTasks:) name:TasksDueTodayDidLoadNotification object:nil];
	
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
	if ([CLLocationManager locationServicesEnabled]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidFix) name:GPSLocationDidFix object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidStop) name:GPSLocationDidStop object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldCheckWithinTasks:) name:TasksWithinDidLoadNotification object:nil];
		[self.locationGetter startUpdates];
	}
}

- (void)refreshAllControllers
{
	[self enableGPS];
	[[APIServices sharedAPIServices]refreshGroups];
	[self refreshTasksForLocalNotification];
	// todo refres tasks
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
		
		// todo get this value from the user's default
		if (!self.lastCurrentLocation || [self.currentLocation distanceFromLocation:self.lastCurrentLocation] >= 1000) {
			[[APIServices sharedAPIServices]refreshTasksWithLatitude:coordinate.latitude longitude:coordinate.longitude within:1.0]; // TODO within user's pref
		}
			
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
	
	self.lastCurrentLocation = self.currentLocation;
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
#pragma mark LocalNotifications

- (void)refreshTasksForLocalNotification
{
	[[APIServices sharedAPIServices]refreshTasksEdited];
	[[APIServices sharedAPIServices]refreshTasksDueToday];
}

- (void)shouldCheckWithinTasks:(NSNotification *)notification
{
	NSArray *newTasks = [[notification object] valueForKey:@"tasks"];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isClose == %@", [NSNumber numberWithBool:TRUE]];
	NSArray *closeTasks = [newTasks filteredArrayUsingPredicate:predicate];
	
	UIDevice* device = [UIDevice currentDevice];
	UIApplication *app = [UIApplication sharedApplication];
	
	if (closeTasks.count == 1) {
		Task *task = [closeTasks objectAtIndex:0];
		
		if ([device respondsToSelector:@selector(isMultitaskingSupported)] && device.isMultitaskingSupported) {
			UILocalNotification *notification = [[[UILocalNotification alloc] init]autorelease];
			notification.fireDate  = nil;
			notification.timeZone  = [NSTimeZone systemTimeZone];
			notification.alertBody = [NSString stringWithFormat:@"You are close to %@, would you like to view it?", task.name];
			notification.alertAction = @"View";
			notification.applicationIconBadgeNumber = 1;
			notification.soundName= UILocalNotificationDefaultSoundName;
			notification.userInfo = [self userInfoForTask:task today:FALSE];
			[app scheduleLocalNotification:notification];
		}
	} else if (closeTasks.count > 1) {
		if ([device respondsToSelector:@selector(isMultitaskingSupported)] && device.isMultitaskingSupported) {
			UILocalNotification *notification = [[[UILocalNotification alloc] init]autorelease];
			notification.fireDate  = nil;
			notification.timeZone  = [NSTimeZone systemTimeZone];
			notification.alertBody = @"More than one task are close to your current location, would you like to see them?";
			notification.alertAction = @"View";
			notification.applicationIconBadgeNumber = closeTasks.count;
			notification.soundName= UILocalNotificationDefaultSoundName;
			notification.userInfo = [self userInfoForTask:nil today:FALSE];
			[app scheduleLocalNotification:notification];
		}
	}
}

- (NSDictionary *)userInfoForTask:(Task *)task today:(BOOL)today
{
	NSData *taskData = [NSKeyedArchiver archivedDataWithRootObject:task];
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
			taskData, @"taskData",
			[NSNumber numberWithBool:today], @"today",
			nil
			];
}

- (UILocalNotification *)hasLocalNotificationForTaskId:(NSNumber *)taskId today:(BOOL)today
{
	NSArray *notifications =  [[UIApplication sharedApplication]scheduledLocalNotifications];
	for (UILocalNotification *notification in notifications) {
		Task *notificationTask = [NSKeyedUnarchiver unarchiveObjectWithData:[notification.userInfo valueForKey:@"taskData"]];
		if (!notificationTask) {
			return nil;
		}
		
		NSNumber *notificationTaskId = notificationTask.taskId;
		BOOL notificationCurrentToday = [[notification.userInfo valueForKey:@"today"]boolValue];
		if ([taskId isEqualToNumber:notificationTaskId] && today == notificationCurrentToday) {
			return notification;
		}
	}
	return nil;
}

- (void)shouldCheckTodayTasks:(NSNotification *)notification
{
	NSArray *newTasks = [[notification object] valueForKey:@"tasks"];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dueAt != nil && expired == %@", [NSNumber numberWithBool:FALSE]];
	NSArray *dueTasks = [newTasks filteredArrayUsingPredicate:predicate];
	
	UIDevice* device = [UIDevice currentDevice];
	UIApplication *app = [UIApplication sharedApplication];
	
	for (Task *task in dueTasks) {
		if ([device respondsToSelector:@selector(isMultitaskingSupported)] && device.isMultitaskingSupported) {
			UILocalNotification *previousNotification = [self hasLocalNotificationForTaskId:task.taskId today:TRUE];
			if (previousNotification) {
				[[UIApplication sharedApplication]cancelLocalNotification:previousNotification];
			}
			UILocalNotification *notification = [[[UILocalNotification alloc] init]autorelease];
			notification.fireDate  = task.dueAt;;
			notification.timeZone  = [NSTimeZone systemTimeZone];
			notification.alertBody = [NSString stringWithFormat:@"Task %@ is due, would you like to see it?", task.name];
			notification.alertAction = @"View";
			notification.applicationIconBadgeNumber = 1;
			notification.soundName= UILocalNotificationDefaultSoundName;
			notification.userInfo = [self userInfoForTask:task today:TRUE];
			[app scheduleLocalNotification:notification];
		}
	}
}

- (Task *)taskForUserInfo:(NSDictionary *)userInfo
{
	Task *notificationTask = [NSKeyedUnarchiver unarchiveObjectWithData:[userInfo valueForKey:@"taskData"]];
	return notificationTask;
}

- (void)handleLocalNotification:(NSDictionary *)launchOptions
{
	[[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];
	if ([UILocalNotification class]) {
		UILocalNotification *notification = [launchOptions valueForKey:UIApplicationLaunchOptionsLocalNotificationKey];
		[self parseNotification:notification];
	}
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
	if (notification.userInfo) {
		// todo
	}
}

- (void)parseNotification:(UILocalNotification *)notification
{
	if (!notification && !notification.userInfo) {
		return;
	}
	
	Task *notificationTask = [NSKeyedUnarchiver unarchiveObjectWithData:[notification.userInfo valueForKey:@"taskData"]];
	if (notificationTask) {
		[self showTask:notificationTask animated:TRUE];
	} else {
		[self showNearTasksAnimated:TRUE];
	}
}

#pragma mark -
#pragma mark View Task

- (void)showTask:(Task *)task animated:(BOOL)animated
{
	TaskContainerViewController *controller = [[[TaskContainerViewController alloc]initWithNibName:@"TaskContainerView" bundle:nil]autorelease];
	controller.task = task;
	controller.tasks = [NSArray arrayWithObject:task];
	CustomNavigationController *navController = [[[CustomNavigationController alloc]initWithRootViewController:controller]autorelease];
	navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	[navController.customNavigationBar setBackgroundImage:[DefaultStyleSheet sharedDefaultStyleSheet].navBarBackgroundImage
											  forBarStyle:UIBarStyleBlackOpaque];
	[navController.customToolbar setBackgroundImage:[DefaultStyleSheet sharedDefaultStyleSheet].toolbarBackgroundImage
										forBarStyle:UIBarStyleBlackOpaque];
	[navController.customToolbar setShadowImage:[DefaultStyleSheet sharedDefaultStyleSheet].toolbarShadowImage
									forBarStyle:UIBarStyleBlackOpaque];
	[self.navigationController presentModalViewController:navController animated:TRUE];
}

#pragma mark -
#pragma mark View Near Tasks

- (void)showNearTasksAnimated:(BOOL)animated
{
	Group *nearGroup = [Group groupWithId:[NSNumber numberWithInt:NSNotFound]
									 name:NearTasksPlacholder];
	
	TasksContainerViewController *controller = [[[TasksContainerViewController alloc]initWithNibName:@"TasksContainerView" bundle:nil]autorelease];
	controller.group = nearGroup;
	CustomNavigationController *navController = [[[CustomNavigationController alloc]initWithRootViewController:controller]autorelease];
	navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	[navController.customNavigationBar setBackgroundImage:[DefaultStyleSheet sharedDefaultStyleSheet].navBarBackgroundImage
											  forBarStyle:UIBarStyleBlackOpaque];
	[navController.customToolbar setBackgroundImage:[DefaultStyleSheet sharedDefaultStyleSheet].toolbarBackgroundImage
										forBarStyle:UIBarStyleBlackOpaque];
	[navController.customToolbar setShadowImage:[DefaultStyleSheet sharedDefaultStyleSheet].toolbarShadowImage
									forBarStyle:UIBarStyleBlackOpaque];
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

