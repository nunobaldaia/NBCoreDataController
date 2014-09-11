//
//  NSManagedObject+NBExtensions.h
//
//  Copyright (c) 2014 Nuno Baldaia All rights reserved.
//

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
