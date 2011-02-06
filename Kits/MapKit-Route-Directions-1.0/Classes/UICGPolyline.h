//
//  UICGPolyline.h
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface UICGPolyline : NSObject {
	
}

@property (nonatomic, retain, readonly) NSArray *points;
@property (nonatomic, readonly) NSInteger numberOfPoints;

+ (UICGPolyline *)polylineWithDictionaryRepresentation:(NSDictionary *)dictionary;
- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary;

- (CLLocation *)pointAtIndex:(NSInteger)index;

@end
