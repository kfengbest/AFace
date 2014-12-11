//
//  LogoutViewController.m
//  AFace
//
//  Created by Kaven Feng on 12/11/14.
//  Copyright (c) 2014 Kaven Feng. All rights reserved.
//

#import "LogoutViewController.h"
#import "SharedData.h"

@interface LogoutViewController ()

@end

@implementation LogoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onLogout:(id)sender {
    
    [[SharedData theInstance] logout];
    [self performSegueWithIdentifier:@"LogoutSegue" sender:self];
    
}

@end
