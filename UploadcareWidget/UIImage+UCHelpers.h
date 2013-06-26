//
//  UIImage+UCHelpers.h
//  WidgetExample
//
//  Created by Zoreslav Khimich on 10/24/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UCHelpers)

- (UIImage *)imageByScalingToSizeAspectFill:(CGSize)size;

- (UIImage *)imageByScalingToSizeAspectFit:(CGSize)size;

+ (UIImage *)blankImageWithSize:(CGSize)size;

@end
