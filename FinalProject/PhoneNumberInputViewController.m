//
//  PhoneNumberInputViewController.m
//  FinalProject
//
//  Created by Ryan Brenner on 4/22/13.
//  Copyright (c) 2013 AugustRyanBrenner. All rights reserved.
//

#import "PhoneNumberInputViewController.h"
#import "AppDelegate.h"
#import "ConfirmationCodeViewController.h"
#import "AFHTTPClient.h"
#import "MBProgressHUD.h"
#import "SBJson.h"
#import "CoreDataHelper.h"

@interface PhoneNumberInputViewController ()
{
    NSManagedObjectContext *context;
}
@end

@implementation PhoneNumberInputViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[self phoneNumberTextField] setDelegate:self];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    context = [appDelegate managedObjectContext];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.phoneNumberTextField)
    {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        NSString *expression = @"^([0-9]+)?(\\.([0-9]{1,2})?)?$";
        //NSString *expression = @"[235689][0-9]{6}([0-9]{3})?";
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:nil];
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString
                                                            options:0
                                                              range:NSMakeRange(0, [newString length])];
        if (numberOfMatches == 0)
            return NO;
    }
    
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}


- (IBAction)phoneNumberSubmitButton:(UIButton *)sender
{
    // Begin progress HUD
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Sending Code...";
    
    // Grab Phone Number from the text field
    NSString *phoneNumber = self.phoneNumberTextField.text;
    
    // Get device unique ID
    UIDevice *device = [UIDevice currentDevice];
    NSUUID *identifierForVendor = [device identifierForVendor];
    NSString *vendorIdString = [identifierForVendor UUIDString];
    
    
    // Prepare HTTP Request
    NSURL *url = [NSURL URLWithString:@"http://ec2-54-214-119-14.us-west-2.compute.amazonaws.com/iOSFinalProject/"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            vendorIdString, @"vendor_id",
                            phoneNumber, @"phone_number",
                            nil];
    
    [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Successful request
        
        // Formulate a response String and Display it in NSLog
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"Request Successful, response '%@'", responseStr);
        
        // Add Phone Number to Core data PhoneNumber Context
        [CoreDataHelper addObject:phoneNumber toEntity:@"UserInfo" withKey:@"phoneNumber" andContext:context];
        
        // Switch to ConfirmationCodeInput View
        ConfirmationCodeViewController *confirmationCodeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ConfirmationCodeInput"];
        [self presentViewController:confirmationCodeViewController animated:YES completion:nil];
        
        
        // End progress HUD
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        // Failed Request
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // 403 error handler
        if ([error.localizedDescription compare: @" Expected status code in (200-299), got 403"] == TRUE) {
        }
        
        // Log the errors
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        
        // End progress HUD
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
    }];
}


@end
