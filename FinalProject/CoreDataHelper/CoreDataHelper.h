//
//  CoreDataHelper.m
//  FinalProject
//
//  Created by Ryan Brenner on 5/15/13.
//  Copyright (c) 2013 AugustRyanBrenner. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface CoreDataHelper : NSObject

// For adding objects
+(void)addObject:(id)value toEntity:(NSString*)entityName withKey:(NSString*)key andContext:(NSManagedObjectContext *)managedObjectContext;

// For retrieval of objects
+(NSMutableArray *)getObjectsForEntity:(NSString*)entityName withSortKey:(NSString*)sortKey andSortAscending:(BOOL)sortAscending andContext:(NSManagedObjectContext *)managedObjectContext;
+(NSMutableArray *)searchObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate *)predicate andSortKey:(NSString*)sortKey andSortAscending:(BOOL)sortAscending andContext:(NSManagedObjectContext *)managedObjectContext;
+(NSMutableArray *)searchObjectsForEntity:(NSString*)entityName withAttributeName:(NSString*)attributeName withAttributeValue:(NSString*)attributeValue andContext:(NSManagedObjectContext *)managedObjectContext;

// For updating of objects
+(void)updateObjectForEntity:(NSString*)entityName withKey:(NSString*)key withPredicate:(NSPredicate *)predicate andContext:(NSManagedObjectContext *)managedObjectContext toValue:(id)value;

// For deletion of objects
+(BOOL)deleteAllObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate*)predicate andContext:(NSManagedObjectContext *)managedObjectContext;
+(BOOL)deleteAllObjectsForEntity:(NSString*)entityName andContext:(NSManagedObjectContext *)managedObjectContext;

// For counting objects
+(NSUInteger)countForEntity:(NSString *)entityName andContext:(NSManagedObjectContext *)managedObjectContext;
+(NSUInteger)countForEntity:(NSString *)entityName withPredicate:(NSPredicate *)predicate andContext:(NSManagedObjectContext *)managedObjectContext;
+(NSUInteger)countForEntity:(NSString*)entityName withKey:(NSString*)key withKeyValue:(id)keyValue andContext:(NSManagedObjectContext *)managedObjectContext;

@end
