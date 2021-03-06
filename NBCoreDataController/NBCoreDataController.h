//
// NBCoreDataController.h
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

#import <CoreData/CoreData.h>

/**
 Simple and lightweight implementatoin of the elegant 3-context scheme proposed by Marcus Zarra for asynchronous CoreData saving
 
 @discussion Reference: http://www.cocoanetics.com/2012/07/multi-context-coredata/
*/
@interface NBCoreDataController : NSObject

/**
 Persistent store coordinator for the current Core Data stack
 */
@property (strong, nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/**
 Background saving context.
 */
@property (strong, nonatomic, readonly) NSManagedObjectContext *rootContext;

/**
 Main thread managed object context.
 */
@property (strong, nonatomic, readonly) NSManagedObjectContext *mainContext;

/**
 Controller's shared instance
 */
+ (NBCoreDataController *)sharedInstance;

/**
 Builds a new Core Data stack for the given persistent store coordinator
 */
- (void)buildStackWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator;

/**
 @deprecated Save the @c mainContext up to the store, providing a block to perform heavy operations on a background thread
 
 @param block The block that will be performed on a background thread with a temporary private queue concurrency type managed object context
 @param completion The completion block with the saving success result and error
 */
- (void)saveWithBlock:(void (^)(NSManagedObjectContext *localContext))block completion:(void (^)(BOOL success, NSError *error))completion DEPRECATED_ATTRIBUTE;

/**
 @deprecated Save the @c mainContext up to the store
 
 @param completion The completion block with the saving success result and error
 */
- (void)saveWithCompletion:(void (^)(BOOL success, NSError *error))completion DEPRECATED_ATTRIBUTE;

/**
 @deprecated Save the @c mainContext up to the store, providing a block to perform heavy operations on a background thread
 
 @param block The block that will be performed on a background thread with a temporary private queue concurrency type managed object context
 @param success The success block
 @param failure The failure block
 */
- (void)saveWithBlock:(void (^)(NSManagedObjectContext *localContext))block success:(void (^)())success failure:(void (^)(NSError *error))failure;

/**
 @deprecated Save the @c mainContext up to the store
 
 @param success The success block
 @param failure The failure block
 */
- (void)saveWithSuccess:(void (^)())success failure:(void (^)(NSError *error))failure;

/**
 Return the managed object ID from the persistent store.
 
 @param Object ID URI representation
 */
- (NSManagedObjectID *)managedObjectIDForURIRepresentation:(NSURL *)url;

@end
