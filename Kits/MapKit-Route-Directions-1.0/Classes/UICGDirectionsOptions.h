//
//  UICGDirectionsOptions.h
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum UICGTravelModes {
	UICGTravelModeDriving,
	UICGTravelModeWalking,
	UICGTravelModeBicycling
} UICGTravelModes;

@interface UICGDirectionsOptions : NSObject {

}

@property (nonatomic) UICGTravelModes travelMode;
@property (nonatomic) BOOL alternatives;
@property (nonatomic) BOOL avoidHighways;
@property (nonatomic) BOOL avoidTolls;

@property (nonatomic, readonly) NSString *parameterized;

@end
