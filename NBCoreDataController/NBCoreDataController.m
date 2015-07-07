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

@property (strong, nonatomic) NSManagedObjectContext *rootContext;
@property (strong, nonatomic) NSManagedObjectContext *mainContext;
@property (strong, nonatomic) NSManagedObjectContext *inMemoryContext;

@end


@implementation NBCoreDataController {
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
}

+ (NBCoreDataController *)sharedInstance
{
    static NBCoreDataController *_sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[NBCoreDataController alloc] init];
    });
    
    return _sharedInstance;
}

- (void)buildStackWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    _persistentStoreCoordinator = persistentStoreCoordinator;
    _rootContext = nil;
    _mainContext = nil;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    return _persistentStoreCoordinator;
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

- (NSManagedObjectID *)managedObjectIDForURIRepresentation:(NSURL *)url;
{
    return [self.persistentStoreCoordinator managedObjectIDForURIRepresentation:url];
}

#pragma mark - Core Data stack

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

@end
