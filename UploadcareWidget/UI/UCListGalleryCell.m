//
//  UCFlatGalleryCell.m
//  ExampleProject
//
//  Created by Yury Nechaev on 12.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCListGalleryCell.h"
#import "UIView+UCBottomLine.h"

static NSString *const kCellIdentifier = @"fileCell";

@implementation UCListGalleryCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.titleLabel.hidden = NO;
        NSDictionary *views = @{@"imageView":self.imageView,
                                @"titleLabel":self.titleLabel};
        NSDictionary *metrics = @{@"offset":@(15)};
        NSArray *horizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-offset-[imageView]-offset-[titleLabel]|" options:0 metrics:metrics views:views];
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
        
        [self.contentView uc_addBottomLineWithLeading:self.titleLabel];
    }
    return self;
}

+ (NSString *)cellIdentifier {
    return kCellIdentifier;
}

@end
