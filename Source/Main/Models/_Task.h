// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Task.h instead.

#import <CoreData/CoreData.h>















@interface TaskID : NSManagedObjectID {}
@end

@interface _Task : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TaskID*)objectID;



@property (nonatomic, retain) NSDate *completedAt;

//- (BOOL)validateCompletedAt:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *sourceId;

@property long long sourceIdValue;
- (long long)sourceIdValue;
- (void)setSourceIdValue:(long long)value_;

//- (BOOL)validateSourceId:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *contactDetail;

//- (BOOL)validateContactDetail:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *contactName;

//- (BOOL)validateContactName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *info;

//- (BOOL)validateInfo:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *sourceName;

//- (BOOL)validateSourceName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *longitude;

@property double longitudeValue;
- (double)longitudeValue;
- (void)setLongitudeValue:(double)value_;

//- (BOOL)validateLongitude:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *location;

//- (BOOL)validateLocation:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *dueAt;

//- (BOOL)validateDueAt:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *latitude;

@property double latitudeValue;
- (double)latitudeValue;
- (void)setLatitudeValue:(double)value_;

//- (BOOL)validateLatitude:(id*)value_ error:(NSError**)error_;





@end

@interface _Task (CoreDataGeneratedAccessors)

@end

@interface _Task (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCompletedAt;
- (void)setPrimitiveCompletedAt:(NSDate*)value;




- (NSNumber*)primitiveSourceId;
- (void)setPrimitiveSourceId:(NSNumber*)value;

- (long long)primitiveSourceIdValue;
- (void)setPrimitiveSourceIdValue:(long long)value_;




- (NSString*)primitiveContactDetail;
- (void)setPrimitiveContactDetail:(NSString*)value;




- (NSString*)primitiveContactName;
- (void)setPrimitiveContactName:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveInfo;
- (void)setPrimitiveInfo:(NSString*)value;




- (NSString*)primitiveSourceName;
- (void)setPrimitiveSourceName:(NSString*)value;




- (NSNumber*)primitiveLongitude;
- (void)setPrimitiveLongitude:(NSNumber*)value;

- (double)primitiveLongitudeValue;
- (void)setPrimitiveLongitudeValue:(double)value_;




- (NSString*)primitiveLocation;
- (void)setPrimitiveLocation:(NSString*)value;




- (NSDate*)primitiveDueAt;
- (void)setPrimitiveDueAt:(NSDate*)value;




- (NSNumber*)primitiveLatitude;
- (void)setPrimitiveLatitude:(NSNumber*)value;

- (double)primitiveLatitudeValue;
- (void)setPrimitiveLatitudeValue:(double)value_;




@end
