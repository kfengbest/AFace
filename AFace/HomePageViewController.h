//
//  HomePageViewController.h
//  AFace
//
//  Created by Kaven Feng on 12/9/14.
//  Copyright (c) 2014 Kaven Feng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomePageViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *lblUserName;
- (IBAction)onLogout:(id)sender;

@end
