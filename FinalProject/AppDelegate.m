//
//  AppDelegate.m
//  FinalProject
//
//  Created by Ryan Brenner on 4/22/13.
//  Copyright (c) 2013 AugustRyanBrenner. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "PhoneNumberInputViewController.h"
#import "ConfirmationCodeViewController.h"
#import "CoreDataHelper.h"
#import "SBJson.h"
#import "AFNetworking.h"


@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
#pragma mark set root view controller
    
    // Server Confirmation
    
    // Get device unique ID
    UIDevice *device = [UIDevice currentDevice];
    NSUUID *identifierForVendor = [device identifierForVendor];
    NSString *vendorIdString = [identifierForVendor UUIDString];
    
    
    // Prepare HTTP Request
    NSURL *url = [NSURL URLWithString:@"http://ec2-54-214-119-14.us-west-2.compute.amazonaws.com/iOSFinalProject/"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            vendorIdString, @"vendor_id",
                            nil];
    
    // Successful request
    [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"Request Successful, response '%@'", responseStr);
        if ([responseStr.JSONRepresentation compare: @"confirmed"] == NSOrderedSame)
        {
            // Create an NSNumber boolean for confirmed and add it to core data
            NSNumber *confirmationBoolean  = [NSNumber numberWithBool:YES];
            [CoreDataHelper updateObjectForEntity:@"UserInfo" withKey:@"confirmed" withPredicate:nil andContext:self.managedObjectContext toValue:confirmationBoolean];
            
            NSLog(@"core data predicate working");
        }
        else if([CoreDataHelper countForEntity:@"UserInfo" withKey:@"phoneNumber" withKeyValue:responseStr.JSONRepresentation andContext:self.managedObjectContext] > 0)
        {
            // Create an NSNumber boolean for confirmed and add it to core data
            NSNumber *confirmationBoolean  = [NSNumber numberWithBool:NO];
            [CoreDataHelper updateObjectForEntity:@"UserInfo" withKey:@"confirmed" withPredicate:nil andContext:self.managedObjectContext toValue:confirmationBoolean];
            
            NSLog(@"core data working with json parser");
            
        }
        
        // Failed Request
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // 404 error handler
        if ([error.localizedDescription compare: @" Expected status code in (200-299), got 404 Not found"] == TRUE) {
           
            // Create an NSNumber boolean for confirmed and add it to core data
            NSFetchRequest * allRecords = [[NSFetchRequest alloc] init];
            [allRecords setEntity:[NSEntityDescription entityForName:@"UserInfo" inManagedObjectContext:self.managedObjectContext]];
            [allRecords setIncludesPropertyValues:NO]; //only fetch the managedObjectID
            
            NSError * error = nil;
            NSArray * cars = [self.managedObjectContext executeFetchRequest:allRecords error:&error];
            //error handling goes here
            for (NSManagedObject * car in cars) {
                [self.managedObjectContext deleteObject:car];
            }
            NSError *saveError = nil;
            [self.managedObjectContext save:&saveError];
        }
        
        // Log the errors
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
    
    // Core Data Confirmation
    
    
    
    // If statement queries core data and selects proper view
    NSString *storyboardId = @"PhoneNumberInput";
    NSPredicate *testForTrue =
    [NSPredicate predicateWithFormat:@"confirmed == YES"];
    
    if([CoreDataHelper countForEntity:@"UserInfo" withPredicate:testForTrue andContext:self.managedObjectContext] > 0)
    {
        storyboardId =@"MainViewController";
    }
    else if([CoreDataHelper countForEntity:@"UserInfo" andContext:self.managedObjectContext] > 0)
    {
        storyboardId =  @"ConfirmationCodeInput";
    }
    
    // Main storyboard reference is instantiated with storyboard ID
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    // View contoller reference is instantiated with storyboard ID selected in IF statement
    UIViewController *initViewController = [storyboard instantiateViewControllerWithIdentifier:storyboardId];
    
    // Load the selected view controller and make it a key view
    self.window.rootViewController = initViewController;
    [self.window makeKeyAndVisible];
    
    return YES;
    
    // Override point for customization after application launch.
}

-(void)loadViewController:(NSString*)storyboardID
{
    // Main storyboard reference is instantiated with storyboard ID
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    // View contoller reference is instantiated with storyboard ID selected in IF statement
    UIViewController *initViewController = [storyboard instantiateViewControllerWithIdentifier:storyboardID];
    
    // Load the selected view controller and make it a key view
    self.window.rootViewController = initViewController;
    [self.window makeKeyAndVisible];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"FinalProject" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"FinalProject.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
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
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
