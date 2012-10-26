//
//  UIImage+UCHelpers.m
//  WidgetExample
//
//  Created by Zoreslav Khimich on 10/24/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UIImage+UCHelpers.h"

@implementation UIImage (UCHelpers)

- (UIImage *)imageByScalingToSize:(CGSize)desiredSize {
    UIGraphicsBeginImageContextWithOptions(desiredSize, NO, 0.0);
    /* preserve the original aspect ration */
    CGSize targetSize;
    if (self.size.width > self.size.height) {
        targetSize.height = desiredSize.height;
        targetSize.width = self.size.width * (desiredSize.height / self.size.height);
    } else {
        targetSize.width = desiredSize.width;
        targetSize.height = self.size.height * (desiredSize.width / self.size.width);
    }
    /* calculate offsets needed to center the scaled image */
    CGFloat leftOffset = (desiredSize.width-targetSize.width) / 2.f;
    CGFloat topOffset = (desiredSize.width-targetSize.height) / 2.f;
    /* draw! */
    [self drawInRect:CGRectMake(leftOffset, topOffset, targetSize.width, targetSize.height)];
    UIImage *scaled = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaled;
}

@end
