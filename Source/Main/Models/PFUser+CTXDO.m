//
//  PFUser+CTXDO.m
//  ContextDo
//
//  Created by Anthony Mittaz on 17/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PFUser+CTXDO.h"

#define AlertsDistanceWithin @"AlertsDistanceWithin"
#define AlertsDistanceWithinDefaultValue 1.0

@implementation PFUser (CTXDO)

#pragma mark -
#pragma mark Settings

- (CGFloat)alertsDistanceWithin
{
	NSNumber *distance = [self objectForKey:AlertsDistanceWithin];
    if (!distance) {
        return AlertsDistanceWithinDefaultValue;
    }
    
    return distance.floatValue;
}

- (void)setAlertsDistanceWithin:(CGFloat)alertsDistanceWithin
{
	[self setObject:[NSNumber numberWithFloat:alertsDistanceWithin] forKey:AlertsDistanceWithin];
}

@end
