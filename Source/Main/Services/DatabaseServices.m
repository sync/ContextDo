#import "DatabaseServices.h"

@implementation DatabaseServices

@synthesize managedObjectContext, managedObjectModel, persistentStoreCoordinator;

#pragma mark - Utilities

- (void)saveContext
{
    NSError *error = nil;
    if (self.managedObjectContext != nil) {
        if ([self.managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext
{
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Database" withExtension:@"momd"];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [NSURL URLWithString:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Database.sqlite"]];
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return persistentStoreCoordinator;
}


- (NSString *)applicationDocumentsDirectory 
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)dealloc
{
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
    [super dealloc];
}

@end
