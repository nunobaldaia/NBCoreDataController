//
// NBCoreDataController.m
//
// Copyright (c) 2015 Nuno Baldaia - http://nunobaldaia.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "NBCoreDataController.h"

@interface NBCoreDataController ()

@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSManagedObjectContext *rootContext;
@property (strong, nonatomic) NSManagedObjectContext *mainContext;

@property (strong, nonatomic) NSManagedObjectContext *inMemoryContext;

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
    if (block == nil) {
        [self saveWithCompletion:completion];
        return;
    }
    
    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temporaryContext.parentContext = self.mainContext;
    
    __weak typeof(self) weakSelf = self;
    
    [temporaryContext performBlock:^{
        
        // Perform block changes in background to the temporary context
        if (block) {
            block(temporaryContext);
        }
        
        // Save the temporaty context to parent (the main context)
        NSError *error;
        if ([temporaryContext save:&error]) {
            
            // Save the main context up the the store
            [weakSelf saveWithCompletion:completion];
        }
        else {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO, error);
                });
            }
        }
    }];
}

- (void)saveWithCompletion:(void (^)(BOOL success, NSError *error))completion
{
    NSManagedObjectContext *rootContext = self.rootContext;
    NSManagedObjectContext *mainContext = self.mainContext;
    
    // Save the context on the main thread
    [mainContext performBlock:^{
        
        // Save the main context to the root context
        NSError *error;
        if ([mainContext save:&error]) {
            
            // Save the root context to the store (disk) on background
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
                    if (completion) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(NO, error);
                        });
                    }
                }
            }];
        }
        else {
            if (completion) {
                completion(NO, error);
            }
        }
    }];
}

#pragma mark - Core Data stack

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel == nil) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:[self bundleName] withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator == nil) {
        NSString *storePath = [[self bundleName] stringByAppendingString:@".sqlite"];
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:storePath];
        
        NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@YES,
                                  NSInferMappingModelAutomaticallyOption:@YES};
        
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil
                                                            URL:storeURL
                                                        options:options
                                                          error:NULL];
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)rootContext
{
    if (_rootContext == nil) {
        _rootContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_rootContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    return _rootContext;
}

- (NSManagedObjectContext *)mainContext
{
    if (_mainContext == nil) {
        _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _mainContext.parentContext = self.rootContext;
    }
    return _mainContext;
}

#pragma mark - In memory managed object context

- (NSManagedObjectContext *)inMemoryContext
{
    NSPersistentStoreCoordinator *inMemoryPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    [inMemoryPersistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:NULL];
    
    NSManagedObjectContext *inMemoryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    inMemoryContext.persistentStoreCoordinator = inMemoryPersistentStoreCoordinator;
    
    return inMemoryContext;
}

#pragma mark - Helpers

- (NSString *)bundleName
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
