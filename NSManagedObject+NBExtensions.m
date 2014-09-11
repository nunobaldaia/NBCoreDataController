//
//  NSManagedObject+NBExtensions.m
//
//  Copyright (c) 2014 Nuno Baldaia All rights reserved.
//

#import "NSManagedObject+NBExtensions.h"
#import "NBCoreDataController.h"

@implementation NSManagedObject (NBExtensions)

+ (NSString *)nb_entityName
{
    return NSStringFromClass(self);
}

+ (NSArray *)nb_allWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors
{
    return [self nb_allWithPredicate:predicate sortDescriptors:sortDescriptors inContext:[NBCoreDataController sharedInstance].mainContext];
}

+ (NSArray *)nb_allWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context
{
    return [self nb_fetchWithPredicate:predicate sortDescriptors:sortDescriptors fetchLimit:0 fetchOffset:0 inContext:context];
}

+ (instancetype)nb_firstWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors
{
    return [self nb_firstWithPredicate:predicate sortDescriptors:sortDescriptors inContext:[NBCoreDataController sharedInstance].mainContext];
}

+ (instancetype)nb_firstWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context
{
    return [self nb_fetchWithPredicate:predicate sortDescriptors:sortDescriptors fetchLimit:1 fetchOffset:0 inContext:context].firstObject;
}

+ (NSArray *)nb_fetchWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors fetchLimit:(NSUInteger)fetchLimit fetchOffset:(NSUInteger)fetchOffset
{
    return [self nb_fetchWithPredicate:predicate sortDescriptors:sortDescriptors fetchLimit:fetchLimit fetchOffset:fetchOffset inContext:[NBCoreDataController sharedInstance].mainContext];
}

+ (NSArray *)nb_fetchWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors fetchLimit:(NSUInteger)fetchLimit fetchOffset:(NSUInteger)fetchOffset inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self nb_entityName]];
    
    fetchRequest.predicate = predicate;
    fetchRequest.sortDescriptors = sortDescriptors;
    fetchRequest.fetchLimit = fetchLimit;
    fetchRequest.fetchOffset = fetchOffset;
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"ERROR:%@", error);
        return nil;
    }
    
    return results;
}

+ (NSUInteger)nb_countWithPredicate:(NSPredicate *)predicate
{
    return [self nb_countWithPredicate:predicate inContext:[NBCoreDataController sharedInstance].mainContext];
}

+ (NSUInteger)nb_countWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self nb_entityName]];
    
    fetchRequest.predicate = predicate;
    
    NSError *error;
    NSUInteger count = [context countForFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"ERROR:%@", error);
        return 0;
    }
    
    return count;
}

+ (NSNumber *)nb_aggregateOperation:(NSString *)function onAttribute:(NSString *)attributeName withPredicate:(NSPredicate *)predicate
{
    return [self nb_aggregateOperation:function onAttribute:attributeName withPredicate:predicate inContext:[NBCoreDataController sharedInstance].mainContext];
}

+ (NSNumber *)nb_aggregateOperation:(NSString *)function onAttribute:(NSString *)attributeName withPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context
{
    NSExpression *expression = [NSExpression expressionForFunction:function arguments:@[[NSExpression expressionForKeyPath:attributeName]]];
    
    NSExpressionDescription *expressionDescription = [NSExpressionDescription new];
    [expressionDescription setName:@"result"];
    [expressionDescription setExpression:expression];
    [expressionDescription setExpressionResultType:NSInteger64AttributeType];
    
    NSArray *properties = @[expressionDescription];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self nb_entityName]];
    [fetchRequest setPropertiesToFetch:properties];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"ERROR:%@", error);
        return nil;
    }
    
    NSDictionary *resultsDictionary = results.firstObject;
    return resultsDictionary[@"result"];
}

+ (instancetype)nb_insert
{
    return [self nb_insertInContext:[NBCoreDataController sharedInstance].mainContext];
}

+ (instancetype)nb_insertInContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self nb_entityName] inManagedObjectContext:context];
}

+ (instancetype)nb_objectWithID:(NSManagedObjectID *)objectID
{
    return [self nb_objectWithID:objectID inContext:[NBCoreDataController sharedInstance].mainContext];
}

+ (instancetype)nb_objectWithID:(NSManagedObjectID *)objectID inContext:(NSManagedObjectContext *)context
{
    return [context objectWithID:objectID];
}

+ (void)nb_deleteWithPredicate:(NSPredicate *)predicate
{
    return [self nb_deleteWithPredicate:predicate inContext:[NBCoreDataController sharedInstance].mainContext];
}

+ (void)nb_deleteWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context
{
    for (NSManagedObject *object in [self nb_allWithPredicate:predicate sortDescriptors:nil inContext:context]) {
        [context deleteObject:object];
    }
}

- (void)nb_delete
{
    [self nb_deleteInContext:self.managedObjectContext];
}

- (void)nb_deleteInContext:(NSManagedObjectContext *)context
{
    [context deleteObject:[self nb_inContext:context]];
}

- (id)nb_inContext:(NSManagedObjectContext *)context
{
    return [context objectWithID:self.objectID];
}

@end
