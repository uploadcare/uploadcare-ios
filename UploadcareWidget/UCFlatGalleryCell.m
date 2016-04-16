//
//  UCFlatGalleryCell.m
//  ExampleProject
//
//  Created by Yury Nechaev on 12.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCFlatGalleryCell.h"
#import "UCSocialEntry.h"
#import "UCClient.h"
#import "UIImageView+Uploadcare.h"

@implementation UCFlatGalleryCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor colorWithWhite:.73 alpha:1.0];
        _imageView = [[UIImageView alloc]init];
        _titleLabel = [[UILabel alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        self.imageView.frame = frame;
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.titleLabel];
        NSDictionary *views = @{@"imageView":self.imageView,
                                @"titleLabel":self.titleLabel};
        [self.imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSDictionary *metrics = @{@"frameHeight":@(frame.size.height)};
        NSArray *horizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView(frameHeight)]-4-[titleLabel]|" options:0 metrics:metrics views:views];
        NSArray *vertical1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics:nil views:views];
        NSArray *vertical2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleLabel]|" options:0 metrics:nil views:views];
        [self.contentView addConstraints:horizontal];
        [self.contentView addConstraints:vertical1];
        [self.contentView addConstraints:vertical2];
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

@end
