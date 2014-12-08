//
//  ViewController.h
//  AFace
//
//  Created by Kaven Feng on 12/5/14.
//  Copyright (c) 2014 Kaven Feng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UINavigationControllerDelegate,
                                            UIImagePickerControllerDelegate,
                                            UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *userName;
@property (strong, nonatomic) IBOutlet UITextField *userPsw;
@property (strong, nonatomic) IBOutlet UIImageView *userPhoto;

@property (strong, nonatomic) NSString *userToken;
@property (strong, nonatomic) NSString *photoName;

- (IBAction)onLogin:(id)sender;

@end

