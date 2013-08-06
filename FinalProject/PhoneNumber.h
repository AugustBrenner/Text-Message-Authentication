//
//  PhoneNumber.h
//  FinalProject
//
//  Created by Ryan Brenner on 4/22/13.
//  Copyright (c) 2013 AugustRyanBrenner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhoneNumber : NSObject

@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic) BOOL *confirmed;
@property (nonatomic) NSInteger *confirmationCode;
@property (nonatomic) NSInteger *confirmationInput;

@end
