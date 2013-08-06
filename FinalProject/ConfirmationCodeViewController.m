//
//  ConfirmationCodeViewController.m
//  FinalProject
//
//  Created by Ryan Brenner on 4/23/13.
//  Copyright (c) 2013 AugustRyanBrenner. All rights reserved.
//

#import "ConfirmationCodeViewController.h"
#import "MBProgressHUD.h"
#import "SBJson.h"
#import "AFNetworking.h"
#import "MainViewController.h"
#import "AppDelegate.h"
#import "CoreDataHelper.h"


@interface ConfirmationCodeViewController ()
{
    NSManagedObjectContext *context;
}
@end

@implementation ConfirmationCodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    context = [appDelegate managedObjectContext];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)confirmationCodeSubmitButton:(id)sender {
    
    // Begin progress HUD
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Sending Code...";
    
    // Grab Phone Number from the text field and clear
    NSString *confirmationCode = self.confirmationCodeTextField.text;
    self.confirmationCodeTextField.text = NULL;
    
    // Get device unique ID
    UIDevice *device = [UIDevice currentDevice];
    NSUUID *identifierForVendor = [device identifierForVendor];
    NSString *vendorIdString = [identifierForVendor UUIDString];
    
    
    // Prepare HTTP Request
    NSURL *url = [NSURL URLWithString:@"http://ec2-54-214-119-14.us-west-2.compute.amazonaws.com/iOSFinalProject/"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            vendorIdString, @"vendor_id",
                            confirmationCode, @"unlock_code",
                            nil];
    
    
        //Successful request
    [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"Request Successful, response '%@'", responseStr);
        if ([responseStr.JSONRepresentation compare: vendorIdString] == NSOrderedSame) {
            
            // Create an NSNumber boolean for confirmed and add it to core data
            NSNumber *confirmationBoolean  = [NSNumber numberWithBool:YES];
            [CoreDataHelper updateObjectForEntity:@"UserInfo" withKey:@"confirmed" withPredicate:nil andContext:context toValue:confirmationBoolean];
            
            //Switch to Main View
            MainViewController *mainPageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
            [self presentViewController:mainPageViewController animated:YES completion:nil];

            
            // End progress HUD
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
        } else {
            //textView.text = [NSString stringWithFormat:@"Received unexpected unlock code: %@", responseStr.JSONRepresentation];
        }
        
        // Failed request
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // 400 error handler
        if ([error.localizedDescription compare: @" Expected status code in (200-299), got 400 "] == TRUE) {
        
            // Show invalid Code message in texfield
            self.confirmationCodeTextField.placeholder = @"Invalid Code";
        
        }
        
        // Log the errors
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        
        // End progress HUD
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];

}
@end
