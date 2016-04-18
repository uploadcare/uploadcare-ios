//
//  UCFlatGalleryCell.h
//  ExampleProject
//
//  Created by Yury Nechaev on 12.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UCSocialEntry;

@interface UCListGalleryCell : UICollectionViewCell
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong) UCSocialEntry *socialEntry;
@end
