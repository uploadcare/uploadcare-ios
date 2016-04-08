//
//  UCGalleryCell.h
//  ExampleProject
//
//  Created by Yury Nechaev on 08.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UCSocialEntry;

@interface UCGalleryCell : UICollectionViewCell
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong) UCSocialEntry *socialEntry;
@end
