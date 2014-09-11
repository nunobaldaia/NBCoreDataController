//
//  NBCoreDataController.m
//
//  Copyright (c) 2014 Nuno Baldaia All rights reserved.
//

/*
 Reference: http://www.cocoanetics.com/2012/07/multi-context-coredata/
 */
#import "NBCoreDataController.h"

@interface NBCoreDataController ()

@property (strong, nonatomic) NSManagedObjectContext *mainContext;
@property (strong, nonatomic) NSManagedObjectContext *rootContext;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@end


@implementation NBCoreDataController

+ (NBCoreDataController *)sharedInstance
{
    static NBCoreDataController *sharedInstance = nil;
    static dispatch_once_t onceToken; // onceToken = 0
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NBCoreDataController alloc] init];
    });
    
    return sharedInstance;
}

- (void)saveWithBlock:(void (^)(NSManagedObjectContext *localContext))block completion:(void (^)(BOOL success, NSError *error))completion
{
    NSManagedObjectContext *rootContext = self.rootContext;
    NSManagedObjectContext *mainContext = self.mainContext;
    
    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temporaryContext.parentContext = mainContext;
    
    [temporaryContext performBlock:^{
        
        // Call a block to perform changes on temporaryContext in background
        if (block) {
            block(temporaryContext);
        }
        
        // Save to parent
        NSError *error;
        if ([temporaryContext save:&error]) {
            
            // Save the context on the main thread
            [mainContext performBlock:^{
                
                // Save main context
                NSError *error;
                if ([mainContext save:&error]) {
                    
                    // Save to disk on background
                    [rootContext performBlock:^{
                        
                        NSError *error;
                        if ([rootContext save:&error]) {
                            
                            if (completion) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    completion(YES, nil);
                                });
                            }
                        }
                        else {
                            if (error) {
                                NSLog(@"ERROR saving root context:%@", error);
                            }
                            if (completion) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    completion(NO, error);
                                });
                            }
                        }
                    }];
                    
                }
                else {
                    if (error) {
                        NSLog(@"ERROR saving main context:%@", error);
                    }
                    if (completion) {
                        completion(NO, error);
                    }
                }
                
            }];
            
        }
        else {
            if (error) {
                NSLog(@"ERROR saving temporary context:%@", error);
            }
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO, error);
                });
            }
        }
    }];
}

#pragma mark - Core Data stack

// Returns the writer managed object context
- (NSManagedObjectContext *)rootContext
{
    if (_rootContext == nil) {
        _rootContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_rootContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    return _rootContext;
}

// Returns the main thread managed object context
- (NSManagedObjectContext *)mainContext
{
    if (_mainContext == nil) {
        _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _mainContext.parentContext = self.rootContext;
    }
    return _mainContext;
}

// Returns the persistent store coordinator for the application.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator == nil) {
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[[self bundleName] stringByAppendingString:@".sqlite"]];
        
        NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES};
        
        NSError *error = nil;
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             
             Typical reasons for an error here include:
             * The persistent store is not accessible;
             * The schema for the persistent store is incompatible with current managed object model.
             Check the error message to determine what the actual problem was.
             
             
             If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
             
             If you encounter schema incompatibility errors during development, you can reduce their frequency by:
             * Simply deleting the existing store:
             [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
             
             * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
             @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
             
             Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
             
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]); // TODO: Log this error
            abort();
        }
    }
    return _persistentStoreCoordinator;
}

// Return the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel == nil) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:[self bundleName] withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Private

- (NSString *)bundleName
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
}

@end
