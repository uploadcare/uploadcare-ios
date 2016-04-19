//
//  UCFlatGalleryCell.m
//  ExampleProject
//
//  Created by Yury Nechaev on 12.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCListGalleryCell.h"
#import "UCSocialEntry.h"
#import "UCClient.h"
#import "UIImageView+Uploadcare.h"

@implementation UCListGalleryCell

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
        NSDictionary *views = @{@"imageView":self.imageView,
                                @"titleLabel":self.titleLabel};
        [self.imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSArray *horizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-25-[imageView]-20-[titleLabel]|" options:0 metrics:nil views:views];
        NSArray *vertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleLabel]|" options:0 metrics:nil views:views];
        
        [self.contentView  addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                                    attribute:NSLayoutAttributeWidth
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1.0
                                                                     constant:15]];
        [self.contentView  addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1.0
                                                                     constant:15]];
        [self.contentView addConstraint:
         [NSLayoutConstraint constraintWithItem:self.imageView
                                      attribute:NSLayoutAttributeCenterY
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.contentView
                                      attribute:NSLayoutAttributeCenterY
                                     multiplier:1
                                       constant:0]];
        
        [self.contentView addConstraints:horizontal];
        [self.contentView addConstraints:vertical];
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
