//
//  NBCoreDataController.h
//
//  Copyright (c) 2014 Nuno Baldaia All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NBCoreDataController : NSObject

@property (strong, nonatomic, readonly) NSManagedObjectContext *mainContext;
@property (strong, nonatomic, readonly) NSManagedObjectContext *rootContext;
@property (strong, nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic, readonly) NSManagedObjectModel *managedObjectModel;

+ (NBCoreDataController *)sharedInstance;

/**
 Save the `mainContext` with a block to perform heavy operations on a background thread
 
 @param block The block that will be performed on a background thread with a temporary private queue concurrency type managed object context
 @param completion The completion block that is performed after the changes has been stored
 */
- (void)saveWithBlock:(void (^)(NSManagedObjectContext *localContext))block completion:(void (^)(BOOL success, NSError *error))completion;

@end
