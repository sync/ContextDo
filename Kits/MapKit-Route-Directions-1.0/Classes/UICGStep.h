//
//  UICGStep.h
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "UICGPolyline.h"

@interface UICGStep : NSObject {
	
}

@property (nonatomic, retain, readonly) NSString *travelMode;
@property (nonatomic, retain, readonly) CLLocation *startLocation;
@property (nonatomic, retain, readonly) CLLocation *endLocation;
@property (nonatomic, retain, readonly) UICGPolyline *polyline;
@property (nonatomic, retain, readonly) NSDictionary *duration;
@property (nonatomic, retain, readonly) NSString *htmlInstructions;
@property (nonatomic, retain, readonly) NSDictionary *distance;


+ (UICGStep *)stepWithDictionaryRepresentation:(NSDictionary *)dictionary;
- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary;

@end
