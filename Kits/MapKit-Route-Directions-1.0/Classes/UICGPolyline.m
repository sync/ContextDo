//
//  UICGPolyline.m
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import "UICGPolyline.h"

@interface UICGPolyline ()

@property (nonatomic, retain) NSArray *points;
@property (nonatomic) NSInteger numberOfPoints;

@end


@implementation UICGPolyline

@synthesize points, numberOfPoints;

+ (UICGPolyline *)polylineWithDictionaryRepresentation:(NSDictionary *)dictionary {
	UICGPolyline *polyline = [[UICGPolyline alloc] initWithDictionaryRepresentation:dictionary];
	return [polyline autorelease];
}

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary {
	self = [super init];
	if (self != nil) {
		NSString *pointsString = [dictionary valueForKey:@"points"];
		
		NSMutableArray *newPoints = [NSMutableArray arrayWithCapacity:0];
		
		// inspired by http://iphonegeeksworld.wordpress.com/2010/09/08/drawing-routes-onto-mkmapview-using-unofficial-google-maps-directions-api/
		NSInteger len = [pointsString length];
		NSInteger index = 0;
		NSInteger lat=0;
		NSInteger lng=0;
		while (index < len) {
			NSInteger b;
			NSInteger shift = 0;
			NSInteger result = 0;
			do {
				b = [pointsString characterAtIndex:index++] - 63;
				result |= (b & 0x1f) << shift;
				shift += 5;
			} while (b >= 0x20);
			NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
			lat += dlat;
			shift = 0;
			result = 0;
			do {
				b = [pointsString characterAtIndex:index++] - 63;
				result |= (b & 0x1f) << shift;
				shift += 5;
			} while (b >= 0x20);
			NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
			lng += dlng;
			NSNumber *latitude = [[[NSNumber alloc] initWithFloat:lat * 1e-5] autorelease];
			NSNumber *longitude = [[[NSNumber alloc] initWithFloat:lng * 1e-5] autorelease];
			CLLocation *loc = [[[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]] autorelease];
			[newPoints addObject:loc];
		}
		self.points = [NSArray arrayWithArray:newPoints];
		self.numberOfPoints = self.points.count;
	}
	return self;
}

- (CLLocation *)pointAtIndex:(NSInteger)index {
	if (index >= self.points.count) {
		return nil;
	}
	
	return [self.points objectAtIndex:index];
}

- (void)dealloc {
	[points release];
	
	[super dealloc];
}

@end
