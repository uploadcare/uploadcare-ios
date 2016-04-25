//
//  UIView+UCBottomLine.m
//  ExampleProject
//
//  Created by Yury Nechaev on 25.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UIView+UCBottomLine.h"

@implementation UIView (UCBottomLine)

- (void)uc_addBottomLineWithLeading:(UIView *)leadingView {
    UIView *pixelView = [[UIView alloc] init];
    pixelView.backgroundColor = [UIColor lightGrayColor];
    [pixelView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:pixelView];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:pixelView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:pixelView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:leadingView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:pixelView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f]];
    [self  addConstraint:[NSLayoutConstraint constraintWithItem:pixelView
                                                      attribute:NSLayoutAttributeHeight
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:nil
                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                     multiplier:1.0
                                                       constant:1.0 / [UIScreen mainScreen].scale]];
}

@end
