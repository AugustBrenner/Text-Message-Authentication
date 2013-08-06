//
//  PhoneNumberInputViewController.h
//  FinalProject
//
//  Created by Ryan Brenner on 4/22/13.
//  Copyright (c) 2013 AugustRyanBrenner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhoneNumberInputViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;

- (IBAction)phoneNumberSubmitButton:(UIButton *)sender;


@end
