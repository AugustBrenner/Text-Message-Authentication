//
//  CoreDataHelper.m
//  FinalProject
//
//  Created by Ryan Brenner on 5/15/13.
//  Copyright (c) 2013 AugustRyanBrenner. All rights reserved.
//


#import "CoreDataHelper.h"

@implementation CoreDataHelper

#pragma mark - Store objects

// Store object
+(void)addObject:(id)value toEntity:(NSString*)entityName withKey:(NSString*)key andContext:(NSManagedObjectContext *)managedObjectContext
{
    // Create entity
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];

    // Create Managed Object
    NSManagedObject *managedObject = [[NSManagedObject alloc]initWithEntity:entityDescription insertIntoManagedObjectContext:managedObjectContext];

    // Store values in Core Data
    [managedObject setValue:value forKey:key];
    
    // Save Changes
    NSError *error;
    [managedObjectContext save:&error];
}


#pragma mark - Retrieve objects

// Fetch objects with a predicate
+(NSMutableArray *)searchObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate *)predicate andSortKey:(NSString*)sortKey andSortAscending:(BOOL)sortAscending andContext:(NSManagedObjectContext *)managedObjectContext
{
	// Create fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];	
	
	// If a predicate was specified then use it in the request
	if (predicate != nil)
		[request setPredicate:predicate];
	
	// If a sort key was passed then use it in the request
	if (sortKey != nil) {
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:sortAscending];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		[request setSortDescriptors:sortDescriptors];
	}
	
	// Execute the fetch request
	NSError *error = nil;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	// If the returned array was nil then there was an error
	if (mutableFetchResults == nil)
		NSLog(@"Couldn't get objects for entity %@", entityName);
	
	// Return the results
	return mutableFetchResults;
}

// Fetch objects With attributes and values
+(NSMutableArray *)searchObjectsForEntity:(NSString*)entityName withKey:(NSString*)key withKeyValue:(NSString*)keyValue andContext:(NSManagedObjectContext *)managedObjectContext
{
    // Design a predicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K like '%@'",
                              key, keyValue];
    // Return the results
    return [self searchObjectsForEntity:entityName withPredicate:predicate andSortKey:nil andSortAscending:TRUE andContext:managedObjectContext];
}

// Fetch objects without a predicate
+(NSMutableArray *)getObjectsForEntity:(NSString*)entityName withSortKey:(NSString*)sortKey andSortAscending:(BOOL)sortAscending andContext:(NSManagedObjectContext *)managedObjectContext
{
    return [self searchObjectsForEntity:entityName withPredicate:nil andSortKey:sortKey andSortAscending:sortAscending andContext:managedObjectContext];
}

#pragma mark - Update objects

// Update objects with a predicate
+(void)updateObjectForEntity:(NSString*)entityName withKey:(NSString*)key withPredicate:(NSPredicate *)predicate andContext:(NSManagedObjectContext *)managedObjectContext toValue:(id)value
{
    // Fetch the object
    NSMutableArray *mutableFetchResults = [self searchObjectsForEntity:entityName withPredicate:predicate andSortKey:nil andSortAscending:FALSE andContext:managedObjectContext];
    
    // Update the object
    [mutableFetchResults.lastObject setValue:value forKey:key];
    
    // Save Changes
    NSError *error;
    [managedObjectContext save:&error];
}


#pragma mark - Count objects

// Get a count for an entity with a predicate
+(NSUInteger)countForEntity:(NSString *)entityName withPredicate:(NSPredicate *)predicate andContext:(NSManagedObjectContext *)managedObjectContext
{
	// Create fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	[request setIncludesPropertyValues:NO];
	
	// If a predicate was specified then use it in the request
	if (predicate != nil)
		[request setPredicate:predicate];
	
	// Execute the count request
	NSError *error = nil;
	NSUInteger count = [managedObjectContext countForFetchRequest:request error:&error];
	
	// If the count returned NSNotFound there was an error
	if (count == NSNotFound)
		NSLog(@"Couldn't get count for entity %@", entityName);
	
	// Return the results
	return count;
}

// Get a count for an entity without a predicate
+(NSUInteger)countForEntity:(NSString *)entityName andContext:(NSManagedObjectContext *)managedObjectContext
{
	return [self countForEntity:entityName withPredicate:nil andContext:managedObjectContext];
}

// Get a count for an entity by value of key;
+(NSUInteger)countForEntity:(NSString*)entityName withKey:(NSString*)key withKeyValue:(id)keyValue andContext:(NSManagedObjectContext *)managedObjectContext
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K like '%@'",
                              key, keyValue];
    return [self countForEntity:entityName withPredicate:predicate andContext:managedObjectContext];
}


#pragma mark - Delete Objects

// Delete all objects for a given entity
+(BOOL)deleteAllObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate*)predicate andContext:(NSManagedObjectContext *)managedObjectContext
{
	// Create fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];	
	
	// Ignore property values for maximum performance
	[request setIncludesPropertyValues:NO];
	
	// If a predicate was specified then use it in the request
	if (predicate != nil)
		[request setPredicate:predicate];
	
	// Execute the count request
	NSError *error = nil;
	NSArray *fetchResults = [managedObjectContext executeFetchRequest:request error:&error];
	
	// Delete the objects returned if the results weren't nil
	if (fetchResults != nil) {
		for (NSManagedObject *manObj in fetchResults) {
			[managedObjectContext deleteObject:manObj];
		}
	} else {
		NSLog(@"Couldn't delete objects for entity %@", entityName);
		return NO;
	}
	
	return YES;	
}

+(BOOL)deleteAllObjectsForEntity:(NSString*)entityName andContext:(NSManagedObjectContext *)managedObjectContext
{
	return [self deleteAllObjectsForEntity:entityName withPredicate:nil andContext:managedObjectContext];
}

@end