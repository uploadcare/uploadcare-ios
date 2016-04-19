//
//  UCGalleryCell.m
//  ExampleProject
//
//  Created by Yury Nechaev on 19.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCGalleryCell.h"
#import "UCSocialEntry.h"
#import "UCClient.h"
#import "UIImageView+Uploadcare.h"

@implementation UCGalleryCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        _imageView = [[UIImageView alloc]init];
        _titleLabel = [[UILabel alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        self.imageView.frame = frame;
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView.layer setShouldRasterize:YES];
        [self.contentView.layer setRasterizationScale:[UIScreen mainScreen].scale];
    }
    return self;
}

- (void)setSocialEntry:(UCSocialEntry *)socialEntry {
    if (![_socialEntry isEqual:socialEntry]) {
        self.imageView.image = nil;
        [self.imageView uc_setImageWithURL:socialEntry.thumbnailUrl usingSession:[[UCClient defaultClient] session] cache:[[UCClient defaultClient] cache]];
    }
    [self.titleLabel setText:socialEntry.title];
    _socialEntry = socialEntry;
}

+ (NSString *)cellIdentifier {
    return @"cell";
}

@end
