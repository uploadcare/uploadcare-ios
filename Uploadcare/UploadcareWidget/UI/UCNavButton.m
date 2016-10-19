//
//  UCNavButton.m
//  ExampleProject
//
//  Created by Yury Nechaev on 19.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCNavButton.h"
#import "UIImage+Bundle.h"

@implementation UCNavButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.minimumScaleFactor = 0.7;
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:[UIFont labelFontSize]]];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setImage:[UIImage imageNamed:@"nav-arrow.png" inBundle:[NSBundle bundleForClass:self.class]] forState:UIControlStateNormal];
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
        
        imageFrame.origin.y = labelFrame.size.height + labelFrame.origin.y - label.font.lineHeight + label.font.xHeight;
        
        imageView.frame = imageFrame;
        label.frame = labelFrame;
    }
}

@end
