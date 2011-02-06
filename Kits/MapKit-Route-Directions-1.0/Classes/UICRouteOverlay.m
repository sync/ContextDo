#import "UICRouteOverlay.h"

@interface UICRouteOverlay ()

@property (nonatomic, retain) NSArray *points;
@property (nonatomic, retain) MKPolyline *polyline;
@property (nonatomic) MKMapRect mapRect;
- (void)loadRoute;

@end


@implementation UICRouteOverlay

@synthesize points, polyline, mapRect;

+ (id)routeOverlayWithPoints:(NSArray *)points;
{
	UICRouteOverlay *overlay = [[[UICRouteOverlay alloc]init]autorelease];
	overlay.points = points;
	[overlay loadRoute];
	
	return overlay;
}

// inspired by
// http://spitzkoff.com/craig/?p=136

// creates the route (MKPolyline) overlay
- (void)loadRoute
{
	// while we create the route points, we will also be calculating the bounding box of our route
	// so we can easily zoom in on it. 
	MKMapPoint northEastPoint = MKMapPointMake(0,0); 
	MKMapPoint southWestPoint = MKMapPointMake(0,0);  
	
	// create a c array of points. 
	MKMapPoint* pointArr = malloc(sizeof(CLLocationCoordinate2D) * self.points.count);
	
	for(int idx = 0; idx < self.points.count; idx++)
	{
		
		CLLocation* location = [self.points objectAtIndex:idx];
		
		MKMapPoint point = MKMapPointForCoordinate(location.coordinate);
		
		
		//
		// adjust the bounding box
		//
		
		// if it is the first point, just use them, since we have nothing to compare to yet. 
		if (idx == 0) {
			northEastPoint = point;
			southWestPoint = point;
		}
		else 
		{
			if (point.x > northEastPoint.x) 
				northEastPoint.x = point.x;
			if(point.y > northEastPoint.y)
				northEastPoint.y = point.y;
			if (point.x < southWestPoint.x) 
				southWestPoint.x = point.x;
			if (point.y < southWestPoint.y) 
				southWestPoint.y = point.y;
		}
		
		pointArr[idx] = point;
		
	}
	
	// create the polyline based on the array of points. 
	self.polyline = [MKPolyline polylineWithPoints:pointArr count:self.points.count];
	
	self.mapRect = MKMapRectMake(southWestPoint.x, southWestPoint.y, northEastPoint.x - southWestPoint.x, northEastPoint.y - southWestPoint.y);
	
	// clear the memory allocated earlier for the points
	free(pointArr);
	
}

- (void)dealloc
{
	[points release];
	[polyline release];
	
	[super dealloc];
}

@end
