//
//  UPCGalleryViewCell.m
//  Social Source
//
//  Created by Zoreslav Khimich on 03/03/2013.
//  Copyright (c) 2013 zrxq. All rights reserved.
//

#import "UPCGalleryViewCell.h"

#import <QuartzCore/QuartzCore.h>

@implementation UPCGalleryViewCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor colorWithWhite:.73 alpha:1.0];
        self.contentView.layer.shadowOffset = CGSizeMake(1, 1);
        self.contentView.layer.shadowOpacity = .5f;
        self.contentView.layer.shadowRadius = 1.f;
        CGPathRef shadowPath = CGPathCreateWithRect(self.contentView.frame, nil);
        self.contentView.layer.shadowPath = shadowPath;
        CGPathRelease(shadowPath);
        
        
        self.selectionStyle = AQGridViewCellSelectionStyleGray;
        
        self.imageView = [[UIImageView alloc]init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        self.imageView.frame = frame;
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

@end
