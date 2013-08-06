//
//  ConfirmationCodeViewController.h
//  FinalProject
//
//  Created by Ryan Brenner on 4/23/13.
//  Copyright (c) 2013 AugustRyanBrenner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfirmationCodeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *confirmationCodeTextField;

- (IBAction)confirmationCodeSubmitButton:(id)sender;

@end
