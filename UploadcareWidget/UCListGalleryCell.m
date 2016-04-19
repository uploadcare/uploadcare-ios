//
//  UCFlatGalleryCell.m
//  ExampleProject
//
//  Created by Yury Nechaev on 12.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCListGalleryCell.h"

static NSString *const kCellIdentifier = @"fileCell";

@implementation UCListGalleryCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSDictionary *views = @{@"imageView":self.imageView,
                                @"titleLabel":self.titleLabel};
        NSDictionary *metrics = @{@"offset":@(25)};
        NSArray *horizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-offset-[imageView]-20-[titleLabel]|" options:0 metrics:metrics views:views];
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

+ (NSString *)cellIdentifier {
    return kCellIdentifier;
}

@end
