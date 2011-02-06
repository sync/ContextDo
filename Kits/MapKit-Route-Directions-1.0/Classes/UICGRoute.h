//
//  UICGRoute.h
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "UICGLeg.h"

@interface UICGRoute : NSObject {
	
}

@property (nonatomic, retain, readonly) NSString *summary;
@property (nonatomic, retain, readonly) NSArray *legs;
@property (nonatomic, retain, readonly) UICGPolyline *overviewPolyline;
@property (nonatomic, retain, readonly) NSArray *waypointOrder;
@property (nonatomic, retain, readonly) NSArray *warnings;
@property (nonatomic, retain, readonly) CLLocation *souhtwestLocation;
@property (nonatomic, retain, readonly) CLLocation *northeastLocation;

@property (nonatomic, readonly) NSInteger numberOfLegs;

+ (UICGRoute *)routeWithDictionaryRepresentation:(NSDictionary *)dictionary;
- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary;

- (UICGLeg *)legAtIndex:(NSInteger)index;

@end
