//
//  UICGDirectionsOptions.m
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

// http://code.google.com/apis/maps/documentation/directions/

#import "UICGDirectionsOptions.h"

@implementation UICGDirectionsOptions

@synthesize travelMode, alternatives, avoidHighways, avoidTolls;

- (id)init {
	self = [super init];
	if (self != nil) {
		self.travelMode = UICGTravelModeDriving;
		self.alternatives = FALSE;
		self.avoidHighways = FALSE;
		self.avoidTolls = FALSE;
	}
	return self;
}

- (NSString *)parameterized
{
	NSString *output = @"";
	
	// travel mode
	output = [output stringByAppendingFormat:@"mode="];
	if (self.travelMode == UICGTravelModeDriving) {
		output = [output stringByAppendingFormat:@"driving"];
	} else if (self.travelMode == UICGTravelModeWalking) {
		output = [output stringByAppendingFormat:@"walking"];
	} else if (self.travelMode == UICGTravelModeBicycling) {
		output = [output stringByAppendingFormat:@"bicycling"];
	}
	// alternative routes
	output = [output stringByAppendingFormat:@"alternatives="];
	if (self.alternatives) {
		output = [output stringByAppendingFormat:@"true"];
	} else {
		output = [output stringByAppendingFormat:@"false"];
	}
	// avoid
	// tolls
	output = [output stringByAppendingFormat:@"avoid="];
	if (self.avoidTolls) {
		output = [output stringByAppendingFormat:@"tolls"];
	}
	// highways
	output = [output stringByAppendingFormat:@"avoid="];
	if (self.avoidHighways) {
		output = [output stringByAppendingFormat:@"highways"];
	}
	
	return output;
}

@end
