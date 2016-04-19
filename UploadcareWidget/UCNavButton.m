//
//  UCNavButton.m
//  ExampleProject
//
//  Created by Yury Nechaev on 19.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCNavButton.h"

@implementation UCNavButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.minimumScaleFactor = 0.7;
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setImage:[UIImage imageNamed:@"nav-arrow-10"] forState:UIControlStateNormal];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIImageView *imageView = [self imageView];
    UILabel *label = [self titleLabel];
    
    if (imageView && imageView.center.x < label.center.x) {
        CGRect imageFrame = imageView.frame;
        CGRect labelFrame = label.frame;
        
        labelFrame.origin.x = imageFrame.origin.x;
        imageFrame.origin.x = labelFrame.origin.x + CGRectGetWidth(labelFrame);
        
        imageView.frame = imageFrame;
        label.frame = labelFrame;
    }
}

@end
