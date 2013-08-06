//
//  MainViewController.h
//  FinalProject
//
//  Created by Ryan Brenner on 5/15/13.
//  Copyright (c) 2013 AugustRyanBrenner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end
