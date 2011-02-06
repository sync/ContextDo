//
//  UICRouteAnnotation.m
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import "UICRouteAnnotation.h"

@implementation UICRouteAnnotation

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize annotationType;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord 
				   title:(NSString *)aTitle 
				subtitle:(NSString *)aSubtitle
		  annotationType:(UICRouteAnnotationType)type {
	self = [super init];
	if (self != nil) {
		coordinate = coord;
		title = [aTitle retain];
		subtitle = [aSubtitle retain];
		annotationType = type;
	}
	return self;
}

- (void)dealloc {
	[subtitle release];
	[title release];	
	
	[super dealloc];
}

@end
