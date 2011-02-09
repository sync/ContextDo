#import "TasksMapViewController.h"
#import "UICRouteAnnotation.h"
#import "UICRouteOverlay.h"
#import "TaskAnnotation.h"
#import "TaskContainerViewController.h"
#import "NSDate+Extensions.h"

@interface TasksMapViewController (private)

- (void)showCurrentLocation;
- (void)updateDirections;
- (void)refreshTasks;
- (void)cancelSearch;
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;
- (void)addAllAnnotationsTasksIncludingToday:(BOOL)includingToday;
- (void)reloadTasks:(NSArray *)newTasks;
- (void)restoreFromCached;
- (TaskAnnotation *)annotationForTask:(Task *)aTask;

@end

@implementation TasksMapViewController

@synthesize mapView, tasks, directions, searchBar, group, mainNavController;
@synthesize routeLine, routeLineView, todayTasks, tasksSave, searchString, hasCachedData;

#pragma mark -
#pragma mark Setup

- (NSString *)stringForLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude
{
	return [NSString stringWithFormat:@"%f,%f", latitude, longitude];
}

- (BOOL)isTodayTasks
{
	return [self.group.name isEqualToString:TodaysTasksPlacholder];
}

- (BOOL)isNearTasks
{
	return [self.group.name isEqualToString:NearTasksPlacholder];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	[self.searchBar setBackgroundImage:[DefaultStyleSheet sharedDefaultStyleSheet].navBarBackgroundImage
								 forBarStyle:UIBarStyleBlackOpaque];
	self.searchBar.keyboardAppearance = UIKeyboardAppearanceAlert;
	
	self.mapView.showsUserLocation = TRUE;
    
    self.directions = [UICGDirections sharedDirections];
	self.directions.delegate = self;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:TasksSearchDidLoadNotification object:nil];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:TasksSearchDidLoadNotification];
	
	if (self.isTodayTasks) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreFromCached) name:TasksGraphDueTodayDidLoadNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:TasksDueTodayDidLoadNotification object:nil];
		[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:TasksDueTodayDidLoadNotification];
	} else if (self.isNearTasks) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreFromCached) name:TasksGraphWithinDidLoadNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:TasksWithinDidLoadNotification object:nil];
		[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:TasksWithinDidLoadNotification];
	} else {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreFromCached) name:TasksGraphDidLoadNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadContent:) name:TasksDidLoadNotification object:nil];
		[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]addObserver:self forKey:TasksDidLoadNotification];
	}
	[self refreshTasks];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	
	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:FALSE];
	self.mapView = nil;
	
	self.searchBar = nil;
}

- (TaskAnnotation *)annotationForTask:(Task *)aTask
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"class = %@ && task.taskId == %@", [TaskAnnotation class], aTask.taskId];
    NSArray *annotations = [self.mapView.annotations filteredArrayUsingPredicate:predicate];
    return (annotations.count > 0) ? [annotations objectAtIndex:0] : nil;
}

- (void)clearMapView
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"class = %@ && not task.taskId in %@ && task.taskId != %@", [TaskAnnotation class], [self.tasks valueForKey:@"taskId"], [NSNumber numberWithInteger:NSNotFound]];
    NSArray *annotations = [self.mapView.annotations filteredArrayUsingPredicate:predicate];
    [self.mapView removeAnnotations:annotations];
}

#pragma mark -
#pragma mark BaseLoadingViewCenter Delegate

- (void)baseLoadingViewCenterDidStartForKey:(NSString *)key
{
	if (!self.tasksSave && self.hasCachedData) {
		return;
	}
	
	[self.noResultsView hide:FALSE];
	
	if (!self.loadingView) {
		self.loadingView = [[[MBProgressHUD alloc] initWithView:self.view]autorelease];
		self.loadingView.delegate = self;
		[self.view addSubview:self.loadingView];
		[self.view bringSubviewToFront:self.loadingView];
		[self.loadingView show:TRUE];
	}
	self.loadingView.labelText = @"Loading";
}

#pragma mark -
#pragma mark Actions

- (void)refreshTasks
{
	if (!self.tasksSave) {
		if (self.isTodayTasks) {
			[self restoreFromCached];
			
			[[APIServices sharedAPIServices]refreshTasksDueToday];
		} else if (self.isNearTasks) {
			[self restoreFromCached];
			
			CLLocationCoordinate2D coordinate = [AppDelegate sharedAppDelegate].currentLocation.coordinate;
			[[APIServices sharedAPIServices]refreshTasksWithLatitude:coordinate.latitude longitude:coordinate.longitude];
		} else {
			[self restoreFromCached];
			
			[[APIServices sharedAPIServices]refreshTasksWithGroupId:self.group.groupId];
		}
	} else {
		// search mode
		[[APIServices sharedAPIServices]refreshTasksWithQuery:self.searchString];
	}
}

- (void)refreshAllTasks
{
	if (self.isTodayTasks) {
		[[APIServices sharedAPIServices]refreshTasksDueToday];
	} else if (self.isNearTasks) {
		CLLocationCoordinate2D coordinate = [AppDelegate sharedAppDelegate].currentLocation.coordinate;
		[[APIServices sharedAPIServices]refreshTasksWithLatitude:coordinate.latitude longitude:coordinate.longitude];
	} else {
		[[APIServices sharedAPIServices]refreshTasksWithGroupId:self.group.groupId];
	}
	
	if (self.tasksSave) {
		// search mode
		[[APIServices sharedAPIServices]refreshTasksWithQuery:self.searchString];
	}
}

#pragma mark -
#pragma mark Content reloading

- (void)shouldReloadContent:(NSNotification *)notification
{
	NSArray *newTasks = [notification object];	
	if (![notification.name isEqualToString:TasksSearchDidLoadNotification] && self.tasksSave) {
		self.tasksSave = newTasks;
		return;
	}
	[self reloadTasks:newTasks];
}

- (void)restoreFromCached
{
	NSArray *archivedContent = nil;
	if (self.isTodayTasks) {
		NSString *due = [[NSDate date] getUTCDateWithformat:@"yyyy-MM-dd"];
		archivedContent = [[CacheServices sharedCacheServices].tasksDueTodayDict
						   valueForKeyPath:[NSString stringWithFormat:@"%@.content", due]];
		self.hasCachedData = (archivedContent != nil);
		[self reloadTasks:archivedContent];
	} else if (self.isNearTasks) {
		archivedContent = [CacheServices sharedCacheServices].tasksWithin;
		self.hasCachedData = (archivedContent != nil);
		[self reloadTasks:archivedContent];
	} else {
		archivedContent = [[CacheServices sharedCacheServices].tasksWithGroupIdDict 
						   valueForKeyPath:[NSString stringWithFormat:@"%@.content", self.group.groupId]];
		self.hasCachedData = (archivedContent != nil);
		[self reloadTasks:archivedContent];
	}
}

- (void)reloadTasks:(NSArray *)newTasks
{
	[self.mapView removeOverlay:self.routeLine];
    self.routeLineView = nil;
    
    self.tasks = newTasks;
	
	NSPredicate *todayPredicate = [NSPredicate predicateWithFormat:@"dueAt == nil || dueToday == %@ || expired == %@", 
                                   [NSNumber numberWithBool:TRUE], 
                                   [NSNumber numberWithBool:TRUE]];
    self.todayTasks = [self.tasks filteredArrayUsingPredicate:todayPredicate];
    
    if (self.todayTasks.count == 0) {
		[self addAllAnnotationsTasksIncludingToday:FALSE];
	} else {
        [self updateDirections];
    }
}

- (void)addAllAnnotationsTasksIncludingToday:(BOOL)includingToday
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"not taskId in %@", [self.todayTasks valueForKey:@"taskId"]];
    NSArray *notTodayTasks = [self.tasks filteredArrayUsingPredicate:predicate];
    
    NSArray *allTasks = (includingToday || self.todayTasks.count == 0) ? self.tasks : notTodayTasks;
    if (allTasks.count == 0) {
        return;
    }
    
	CLLocationDegrees maxLat = -90.0f;
	CLLocationDegrees maxLon = -180.0f;
	CLLocationDegrees minLat = 90.0f;
	CLLocationDegrees minLon = 180.0f;
	for (Task *task in allTasks) {
		if (task.taskId.integerValue != NSNotFound) {
			CLLocation *location = [[[CLLocation alloc]initWithLatitude:task.latitude.doubleValue longitude:task.longitude.doubleValue]autorelease];
			TaskAnnotation *annotation = [self annotationForTask:task];
            if (!annotation) {
                annotation = [[[TaskAnnotation alloc] initWithCoordinate:[location coordinate]
                                                                   title:task.name
                                                                subtitle:task.location
                                                          annotationType:UICRouteAnnotationTypeWayPoint] autorelease];
                [self.mapView addAnnotation:annotation];
            } else {
                annotation.title = task.name;
                annotation.subtitle = task.location;
                annotation.coordinate = location.coordinate;
            }
            annotation.task = task;
			
			if(location.coordinate.latitude > maxLat) {
				maxLat = location.coordinate.latitude;
			}
			if(location.coordinate.latitude < minLat) {
				minLat = location.coordinate.latitude;
			}
			if(location.coordinate.longitude > maxLon) {
				maxLon = location.coordinate.longitude;
			}
			if(location.coordinate.longitude < minLon) {
				minLon = location.coordinate.longitude;
			}
		}
	}
	MKCoordinateRegion region;
	region.center.latitude     = (maxLat + minLat) / 2;
	region.center.longitude    = (maxLon + minLon) / 2;
	region.span.latitudeDelta  = maxLat - minLat;
	region.span.longitudeDelta = maxLon - minLon;
    
    if (includingToday) {
        // todo pass including today
        [self clearMapView];
    }
	
	[self.mapView setRegion:region animated:YES];
}

- (void)updateDirections
{
	NSMutableArray *tasksToDirections = [NSMutableArray arrayWithArray:self.todayTasks];
	if (self.mapView.userLocation) {
		CLLocation *startLocation = nil;
		if (TARGET_IPHONE_SIMULATOR) {
			startLocation = [AppDelegate sharedAppDelegate].currentLocation;
		} else {
			startLocation = self.mapView.userLocation.location;
		}
		Task *currentLocation = [Task taskWithId:[NSNumber numberWithInteger:NSNotFound]
											name:CURRENT_LOCATION_PLACEHOLDER
										latitude:startLocation.coordinate.latitude
									   longitude:startLocation.coordinate.longitude];
		[tasksToDirections insertObject:currentLocation atIndex:0];
	}
	self.todayTasks = [NSArray arrayWithArray:tasksToDirections];
	
	UICGDirectionsOptions *options = [[[UICGDirectionsOptions alloc] init] autorelease];
	options.travelMode = UICGTravelModeDriving;
	[self.directions loadFromWaypoints:[self.todayTasks valueForKey:@"latLngString"] options:options];
}

#pragma mark -
#pragma mark UICGDirectionsDelegate

- (void)directionsDidUpdateDirections:(UICGDirections *)aDirections {
	// Overlay polylines
	UICGPolyline *polyline = [[aDirections routeAtIndex:0] overviewPolyline];
	NSArray *routePoints = [polyline points];
	
	if (routePoints.count == 0) {
		[self addAllAnnotationsTasksIncludingToday:TRUE];
		return;
	}
	
	UICRouteOverlay *overlay = [UICRouteOverlay routeOverlayWithPoints:routePoints];
	self.routeLine = overlay.polyline;
	
	[self.mapView addOverlay:self.routeLine];
	[self.mapView setVisibleMapRect:overlay.mapRect];
	
	// here we can have multiple routes todo
	NSInteger numberOfRoutes = [self.directions numberOfRoutes];
	if (numberOfRoutes > 0) {
		UICGRoute *route = [self.directions routeAtIndex:0];
		
		NSArray *waypointOrder = route.waypointOrder;
		NSMutableArray *organizedTasks = [NSMutableArray arrayWithArray:self.todayTasks];
		if (waypointOrder.count > 1) {
			NSInteger index = 1;
			for (NSNumber *orderNum in waypointOrder) {
				NSInteger order = orderNum.integerValue;
				[organizedTasks replaceObjectAtIndex:index withObject:[self.todayTasks objectAtIndex:order+1]];
				index++;
			}
		}
        
        Task *startTask = [organizedTasks objectAtIndex:0];
        TaskAnnotation *startAnnotation = [self annotationForTask:startTask];
        if (!startAnnotation) {
            startAnnotation = [[[TaskAnnotation alloc] initWithCoordinate:[[[route legAtIndex:0]startLocation]coordinate]
                                                                    title:startTask.name
                                                                 subtitle:[[route.legs objectAtIndex:0]startAddress]
                                                           annotationType:UICRouteAnnotationTypeStart] autorelease];
            [self.mapView addAnnotation:startAnnotation];
        } else {
            startAnnotation.title = startTask.name;
            startAnnotation.subtitle = startTask.location;
            startAnnotation.coordinate = [[[route legAtIndex:0]startLocation]coordinate];
        }
        startAnnotation.task = startTask;
		
		for (NSInteger index = 0; index < route.numberOfLegs; index++) {
			if (index == route.numberOfLegs - 1) {
				break;
			}
            
            Task *task = [organizedTasks objectAtIndex:index + 1];
            
            UICGLeg *leg = [route legAtIndex:index];
            TaskAnnotation *annotation = [self annotationForTask:task];
            if (!annotation) {
                annotation = [[[TaskAnnotation alloc] initWithCoordinate:leg.endLocation.coordinate
                                                                        title:task.name
                                                                     subtitle:task.location
                                                               annotationType:UICRouteAnnotationTypeWayPoint] autorelease];
                [self.mapView addAnnotation:annotation];
            } else {
                annotation.title = task.name;
                annotation.subtitle = task.location;
                annotation.coordinate = leg.endLocation.coordinate;
            }
            annotation.task = task;
		}
        
        Task *endTask = [organizedTasks lastObject];
       
        TaskAnnotation *endAnnotation = [self annotationForTask:endTask];
        if (!endAnnotation) {
            endAnnotation = [[[TaskAnnotation alloc] initWithCoordinate:[[[route.legs lastObject]endLocation]coordinate]
                                                                  title:endTask.name
                                                               subtitle:endTask.location
                                                         annotationType:UICRouteAnnotationTypeEnd] autorelease];
            [self.mapView addAnnotation:endAnnotation];
        } else {
            endAnnotation.title = endTask.name;
            endAnnotation.subtitle = endTask.location;
            endAnnotation.coordinate = [[[route.legs lastObject]endLocation]coordinate];
        }
        endAnnotation.task = endTask;
        
        [self clearMapView];
	} else {
		[self addAllAnnotationsTasksIncludingToday:TRUE];
	}
}

- (void)directions:(UICGDirections *)directions didFailWithMessage:(NSString *)message {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Map Directions" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[alertView show];
	[alertView release];
}

#pragma mark -
#pragma mark Map View Delegate + Utilities

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:TRUE];
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:FALSE];
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:FALSE];
}

#pragma mark -
#pragma mark <MKMapViewDelegate> Methods

- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id<MKAnnotation>)annotation {
	static NSString *identifier = @"RoutePinAnnotation";
	
	if ([annotation isKindOfClass:[UICRouteAnnotation class]]) {
		MKPinAnnotationView *pinAnnotation = (MKPinAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:identifier];
		if(!pinAnnotation) {
			pinAnnotation = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
		}
		
		if ([(UICRouteAnnotation *)annotation annotationType] == UICRouteAnnotationTypeStart) {
			pinAnnotation.pinColor = MKPinAnnotationColorGreen;
		} else if ([(UICRouteAnnotation *)annotation annotationType] == UICRouteAnnotationTypeEnd) {
			pinAnnotation.pinColor = MKPinAnnotationColorRed;
		} else {
			pinAnnotation.pinColor = MKPinAnnotationColorPurple;
		}
		
		if (![annotation.title isEqualToString:CURRENT_LOCATION_PLACEHOLDER] && 
			[(UICRouteAnnotation *)annotation annotationType] != UICRouteAnnotationTypeStart) {
			UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
			pinAnnotation.rightCalloutAccessoryView = button;
		}
		
		pinAnnotation.animatesDrop = YES;
		pinAnnotation.enabled = YES;
		pinAnnotation.canShowCallout = YES;
		return pinAnnotation;
	}
	
	return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	if ([view.annotation isKindOfClass:[TaskAnnotation class]]) {
		TaskAnnotation *annotation = (TaskAnnotation *)view.annotation;
		Task *task = annotation.task;
		
		TaskContainerViewController *controller = [[[TaskContainerViewController alloc]initWithNibName:@"TaskContainerView" bundle:nil]autorelease];
		controller.hidesBottomBarWhenPushed = TRUE;
		controller.task = task;
		controller.tasks = self.tasks;
		[self.mainNavController pushViewController:controller animated:TRUE];
	}
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
	MKOverlayView* overlayView = nil;
	if(overlay == self.routeLine) {
		//if we have not yet created an overlay view for this overlay, create it now. 
		if(nil == self.routeLineView) {
			self.routeLineView = [[[MKPolylineView alloc] initWithPolyline:self.routeLine] autorelease];
			self.routeLineView.strokeColor = [UIColor colorWithHexString:@"0000ff50"];
			self.routeLineView.fillColor = [UIColor colorWithHexString:@"0000ff70"];
			
			CGFloat scale = 1.0;
			#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
				if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
					scale = [[UIScreen mainScreen] scale];
				}
			#endif
			self.routeLineView.lineWidth = 4.0 * scale;
		}
		overlayView = self.routeLineView;
	}
	return overlayView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (!scrollView.dragging || scrollView.decelerating) {
		return;
	}
	
	[self.searchBar resignFirstResponder];
	if ([self.searchBar respondsToSelector:@selector(cancelButton)]) {
		[[self.searchBar valueForKey:@"cancelButton"] setEnabled:TRUE];
	}
}

#pragma mark -
#pragma mark Actions

- (void)showCurrentLocation
{
	CLLocation *location = self.mapView.userLocation.location;
	if (!location && self.mapView.userLocation.updating) {
		[self performSelector:@selector(showCurrentLocation) withObject:nil afterDelay:0.5];
	} else {
		if (!self.mapView.showsUserLocation) {
			self.mapView.showsUserLocation = TRUE;
			[self performSelector:@selector(showCurrentLocation) withObject:nil afterDelay:0.5];
		} else {
			// zoom to current location
			[self.mapView setRegion:MKCoordinateRegionMakeWithDistance(location.coordinate, MapViewLocationDefaultSpanInMeters, MapViewLocationDefaultSpanInMeters) animated:TRUE];
		}
	}
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)aSearchBar
{
	if (!aSearchBar.showsCancelButton) {
		self.tasksSave = self.tasks;
		self.tasks = nil;
	}
	
	[aSearchBar setShowsCancelButton:TRUE animated:TRUE];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar
{
	if (aSearchBar.text.length == 0) {
		[self cancelSearch];
	}
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar
{
	if ([aSearchBar.text isEqualToString:self.searchString]) {
		return;
	}
	[self filterContentForSearchText:aSearchBar.text scope:nil];
	
	if ([self.searchBar respondsToSelector:@selector(cancelButton)]) {
		[[self.searchBar valueForKey:@"cancelButton"] setEnabled:TRUE];
	}
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)aSearchBar
{
	[self cancelSearch];
}

- (void)cancelSearch
{
	[self.searchBar setShowsCancelButton:FALSE animated:TRUE];
	[self.searchBar resignFirstResponder];
	self.searchBar.text = nil;
	self.searchString = nil;
	[self reloadTasks:self.tasksSave];
	self.tasksSave = nil;
}

#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[self.searchBar resignFirstResponder];
	self.searchString = searchText;
	
	[self refreshTasks];
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc
{
	[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:FALSE];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:TasksWithinDidLoadNotification];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:TasksDidLoadNotification];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:TasksDueTodayDidLoadNotification];
	[[BaseLoadingViewCenter sharedBaseLoadingViewCenter]removeObserver:self forKey:TasksSearchDidLoadNotification];
	
	self.mapView.delegate = nil;
	self.directions.delegate = nil;
	
	[routeLine release];
	[routeLineView release];
	
	[searchBar release];
	
	[group release];
	
	[todayTasks release];
	[tasksSave release];
	[tasks release];
	[mapView release];
	
	[super dealloc];
}


@end
