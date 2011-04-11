#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DatabaseServices : NSObject {
    
}

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain, readonly) NSString *applicationDocumentsDirectory;

- (void)saveContext;

@end
