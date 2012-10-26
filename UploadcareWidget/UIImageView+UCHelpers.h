//
//  UIImageView+UCHelpers.h
//  WidgetExample
//
//  Created by Zoreslav Khimich on 10/24/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (UCHelpers)
- (void)setImageFromURL:(NSURL *)url imageProcessingBlock:(UIImage *(^)(UIImage *image))imageProcessingBlock;
- (void)setImageFromURL:(NSURL *)url scaledToSize:(CGSize)size;
@end
