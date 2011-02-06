//
//  UICGDirections.h
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UICGDirectionsOptions.h"
#import "UICGRoute.h"
#import "UICGPolyline.h"
#import "GoogleMapApiServices.h"

@protocol UICGDirectionsDelegate;

@interface UICGDirections : NSObject {

}

@property (nonatomic, assign) id<UICGDirectionsDelegate> delegate;
@property (nonatomic, readonly) NSString *status;
@property (nonatomic, readonly) NSArray *routes;

+ (UICGDirections *)sharedDirections;
- (id)init;

@property (nonatomic, retain) GoogleMapApiServices *googleMapApiServices;

@property (nonatomic, readonly) NSInteger numberOfRoutes;
- (UICGRoute *)routeAtIndex:(NSInteger)index;

- (void)loadWithStartPoint:(NSString *)startPoint endPoint:(NSString *)endPoint options:(UICGDirectionsOptions *)options;
- (void)loadFromWaypoints:(NSArray *)waypoints options:(UICGDirectionsOptions *)options;

@end

@protocol UICGDirectionsDelegate<NSObject>
@optional
- (void)directionsDidUpdateDirections:(UICGDirections *)directions;
- (void)directions:(UICGDirections *)directions didFailWithMessage:(NSString *)message;
@end

