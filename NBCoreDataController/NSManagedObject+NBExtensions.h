//
// NSManagedObject+NBExtensions.h
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

@interface NSManagedObject (NBExtensions)

+ (NSString *)nb_entityName;

+ (NSArray *)nb_allWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors;
+ (NSArray *)nb_allWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context;

+ (instancetype)nb_firstWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors;
+ (instancetype)nb_firstWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context;

+ (NSUInteger)nb_countWithPredicate:(NSPredicate *)predicate;
+ (NSUInteger)nb_countWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;

+ (NSNumber *)nb_aggregateOperation:(NSString *)function onAttribute:(NSString *)attributeName withPredicate:(NSPredicate *)predicate;
+ (NSNumber *)nb_aggregateOperation:(NSString *)function onAttribute:(NSString *)attributeName withPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;

+ (NSArray *)nb_fetchWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors fetchLimit:(NSUInteger)fetchLimit fetchOffset:(NSUInteger)fetchOffset;
+ (NSArray *)nb_fetchWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors fetchLimit:(NSUInteger)fetchLimit fetchOffset:(NSUInteger)fetchOffset inContext:(NSManagedObjectContext *)context;

+ (instancetype)nb_insert;
+ (instancetype)nb_insertInContext:(NSManagedObjectContext *)context;

+ (instancetype)nb_objectWithID:(NSManagedObjectID *)objectID;
+ (instancetype)nb_objectWithID:(NSManagedObjectID *)objectID inContext:(NSManagedObjectContext *)context;

+ (void)nb_deleteWithPredicate:(NSPredicate *)predicate;
+ (void)nb_deleteWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;

- (void)nb_delete;
- (void)nb_deleteInContext:(NSManagedObjectContext *)context;

- (id)nb_inContext:(NSManagedObjectContext *)context;

@end
