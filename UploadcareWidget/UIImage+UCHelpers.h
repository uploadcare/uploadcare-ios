//
//  UIImage+UCHelpers.h
//  WidgetExample
//
//  Created by Zoreslav Khimich on 10/24/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UCHelpers)

/** 
 Creates and returns an image object by scaling the receiver's content while preserving the original aspect ratio and cropping the remainder.
 */
- (UIImage *)imageByScalingToSize:(CGSize)size;
@end
