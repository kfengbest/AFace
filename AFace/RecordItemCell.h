//
//  RecordItemCell.h
//  JiZhang
//
//  Created by Kaven Feng on 4/7/14.
//  Copyright (c) 2014 Kaven Feng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RecordItemCellDelegate
-(void) TouchedOnAddPhotoCell;
@end

@interface RecordItemCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end


@interface AddPhotoCell : UICollectionViewCell
@end