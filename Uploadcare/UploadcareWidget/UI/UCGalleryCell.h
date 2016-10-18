//
//  UCGalleryCell.h
//  ExampleProject
//
//  Created by Yury Nechaev on 19.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UCGalleryCellProtocol.h"

@interface UCGalleryCell : UICollectionViewCell <UCGalleryCellProtocol>

@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong) UCSocialEntry *socialEntry;

@end
