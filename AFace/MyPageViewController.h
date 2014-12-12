//
//  MyPageViewController.h
//  AFace
//
//  Created by Kaven Feng on 12/9/14.
//  Copyright (c) 2014 Kaven Feng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyPageViewController : UIViewController<UICollectionViewDelegate,
                                                    UICollectionViewDataSource,
                                                    UINavigationControllerDelegate,
                                                    UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end
