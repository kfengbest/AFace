//
//  HomePageViewController.m
//  AFace
//
//  Created by Kaven Feng on 12/9/14.
//  Copyright (c) 2014 Kaven Feng. All rights reserved.
//

#import "HomePageViewController.h"
#import "SharedData.h"

@interface HomePageViewController ()

@end

@implementation HomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.lblUserName.text = [[SharedData theInstance] getUserFullName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"HomePageViewController:: viewDidAppear");
    self.lblUserName.text = [[SharedData theInstance] getUserFullName];
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
