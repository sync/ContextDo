//
//  UICGRoute.m
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import "UICGRoute.h"

@interface UICGRoute ()

@property (nonatomic, retain) NSString *summary;
@property (nonatomic, retain) NSArray *legs;
@property (nonatomic, retain) UICGPolyline *overviewPolyline;
@property (nonatomic, retain) NSArray *waypointOrder;
@property (nonatomic, retain) NSArray *warnings;
@property (nonatomic, retain) CLLocation *souhtwestLocation;
@property (nonatomic, retain) CLLocation *northeastLocation;
@property (nonatomic) NSInteger numberOfLegs;

@end


@implementation UICGRoute

@synthesize summary, legs, overviewPolyline, waypointOrder, warnings, souhtwestLocation;
@synthesize northeastLocation, numberOfLegs;

+ (UICGRoute *)routeWithDictionaryRepresentation:(NSDictionary *)dictionary {
	UICGRoute *route = [[UICGRoute alloc] initWithDictionaryRepresentation:dictionary];
	return [route autorelease];
}

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary {
	self = [super init];
	if (self != nil) {
		self.summary = [dictionary objectForKey:@"summary"];
		self.overviewPolyline = [UICGPolyline polylineWithDictionaryRepresentation:[dictionary objectForKey:@"overview_polyline"]];
		self.waypointOrder = [dictionary objectForKey:@"waypoint_order"];
		self.warnings = [dictionary objectForKey:@"warnings"];
		NSDictionary *southwestBounds = [dictionary valueForKeyPath:@"bounds.southwest"];
		CLLocationDegrees latitudeSW  = [[southwestBounds objectForKey:@"lat"] doubleValue];
		CLLocationDegrees longitudeSW = [[southwestBounds objectForKey:@"lng"] doubleValue];
		self.souhtwestLocation = [[[CLLocation alloc] initWithLatitude:latitudeSW longitude:longitudeSW]autorelease];
		NSDictionary *northeastBounds = [dictionary valueForKeyPath:@"bounds.northeast"];
		CLLocationDegrees latitudeNE  = [[northeastBounds objectForKey:@"lat"] doubleValue];
		CLLocationDegrees longitudeNE = [[northeastBounds objectForKey:@"lng"] doubleValue];
		self.northeastLocation = [[[CLLocation alloc] initWithLatitude:latitudeNE longitude:longitudeNE]autorelease];
		
		NSArray *legsDict = [dictionary valueForKey:@"legs"];
		self.legs = [NSMutableArray arrayWithCapacity:[legsDict count]];
		for (NSDictionary *legDict in legsDict) {
			[(NSMutableArray *)self.legs addObject:[UICGLeg legWithDictionaryRepresentation:legDict]];
		}
		self.numberOfLegs = self.legs.count;	
	}
	return self;
}

- (UICGLeg *)legAtIndex:(NSInteger)index {
	if (index >= self.legs.count) {
		return nil;
	}
	
	return [self.legs objectAtIndex:index];;
}

- (void)dealloc {
	[summary release];
	[legs release];
	[overviewPolyline release];
	[waypointOrder release];
	[warnings release];
	[souhtwestLocation release];
	[northeastLocation release];
	
	[super dealloc];
}

@end
