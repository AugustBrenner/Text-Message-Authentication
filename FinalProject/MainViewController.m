//
//  MainViewController.m
//  FinalProject
//
//  Created by Ryan Brenner on 5/15/13.
//  Copyright (c) 2013 AugustRyanBrenner. All rights reserved.
//

#import "MainViewController.h"
#import "CoreDataHelper.h"
#import "AppDelegate.h"
#import <AddressBookUI/AddressBookUI.h>
#import "AFHTTPClient.h"
#import "SBJson.h"
#import "JSONHelper.h"

@interface MainViewController ()

@end

@implementation MainViewController
{
    NSArray *contacts;
    
    NSManagedObjectContext *managedObjectContext;

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    managedObjectContext = [appDelegate managedObjectContext];
    
    // Do any additional setup after loading the view.
        
    // Request authorization to Address Book
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            // First time access has been granted, add the contact
            contacts = [NSArray arrayWithObjects:@"AddressBook", @"not", @"querried", nil];
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        
        NSArray *arrayOfPeople =
        (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBookRef);
        NSUInteger index = 0;
        
        NSMutableArray *firstNameArray = [[NSMutableArray alloc] init];
        NSMutableArray *lastNameArray = [[NSMutableArray alloc] init];
        NSMutableArray *phoneNumberArray = [[NSMutableArray alloc] init];
        
        for(index = 0; index<[arrayOfPeople count]; index++){
            
            ABRecordRef currentPerson =
            (__bridge ABRecordRef)[arrayOfPeople objectAtIndex:index];
            
            
            NSString *firstName = (__bridge NSString *)ABRecordCopyValue(currentPerson, kABPersonFirstNameProperty);
            
            NSString *lastName = (__bridge NSString *)ABRecordCopyValue(currentPerson, kABPersonLastNameProperty);
            
            NSArray *phoneNumbers = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(ABRecordCopyValue(currentPerson, kABPersonPhoneProperty));
            
            // Add first and last names to array
            [firstNameArray addObject:firstName];
            [lastNameArray addObject:lastName];
            
            // Make sure that the selected contact has one phone at least filled in.
            if ([phoneNumbers count] > 0) {
                // We'll use the first phone number only here.
                // In a real app, it's up to you to play around with the returned values and pick the necessary value.
                [phoneNumberArray addObject:[phoneNumbers objectAtIndex:0]];
                
            }
            else{
                [phoneNumberArray addObject:nil];
            }
            

        }

               
        // Prepare HTTP Request
        NSURL *url = [NSURL URLWithString:@"http://ec2-54-214-119-14.us-west-2.compute.amazonaws.com/iOSFinalProject/"];
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                [JSONHelper jsonStringFromArray:firstNameArray], @"first_name",
                                [JSONHelper jsonStringFromArray:lastNameArray], @"last_name",
                                [JSONHelper jsonStringFromArray:phoneNumberArray], @"contacts_phone_number",
                                nil];
        
        //Successful request
        [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            
            NSLog(@"Request Successful, response '%@'", responseStr.JSONValue);
            
            NSError *error;
            NSDictionary * jsonResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
            
            NSDictionary *responseFirstNameDictionary = [jsonResponse objectForKey:@"first_name"];
            NSDictionary *responseLastNameDictionary = [jsonResponse objectForKey:@"last_name"];
            NSArray *responsePhoneNumberArray = [jsonResponse objectForKey:@"phone_number"];
            
            NSArray *responseFirstNameArray = [responseFirstNameDictionary allValues];
            NSArray *responseLastNameArray = [responseLastNameDictionary allValues];
            
            NSLog(@"Request Successful, response '%@' '%@' '%@'", [responseFirstNameArray objectAtIndex:0], responseLastNameArray, responsePhoneNumberArray);
            
        
            int index;
            for (index = 0 ; index < responsePhoneNumberArray.count ; index++){
                // Create entity
                NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Contacts" inManagedObjectContext:managedObjectContext];
                
                // Create Managed Object
                NSManagedObject *managedObject = [[NSManagedObject alloc]initWithEntity:entityDescription insertIntoManagedObjectContext:managedObjectContext];
                
                // Store values in Core Data
                [managedObject setValue:[responseFirstNameArray objectAtIndex:index] forKey:@"firstName"];
                [managedObject setValue:[responseLastNameArray objectAtIndex:index] forKey:@"lastName"];
                [managedObject setValue:[responsePhoneNumberArray objectAtIndex:index] forKey:@"phoneNumber"];
            
                // Save Changes
                [managedObjectContext save:&error];
                
            }
            
            

            
            // Failed request
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            // Log the errors
            NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);

        }];
        

    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
        contacts = [NSArray arrayWithArray:[NSArray arrayWithObjects:@"AddressBook", @"never", @"Authorized", nil]];
        
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [contacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"ContactsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [contacts objectAtIndex:indexPath.row];
    return cell;
}


@end
