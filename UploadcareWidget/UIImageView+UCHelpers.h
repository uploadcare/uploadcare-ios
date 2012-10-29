//
//  UIImageView+UCHelpers.h
//  WidgetExample
//
//  Created by Zoreslav Khimich on 10/24/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (UCHelpers)
- (void)setImageFromURL:(NSURL *)url scaledToSize:(CGSize)size successBlock:(void (^)(UIImage *image))successBlock failureBlock:(void (^)(NSError *error))failureBlock;
- (void)setImageFromURL:(NSURL *)url scaledToSize:(CGSize)size placeholderImage:(UIImage *)placeholderImage showActivityIndicator:(BOOL)showIndicator withStyle:(UIActivityIndicatorViewStyle)style;
- (UIActivityIndicatorView *)showActivityIndicatorWithStyle:(UIActivityIndicatorViewStyle)style center:(CGPoint)center;
- (UIActivityIndicatorView *)showActivityIndicatorWithStyle:(UIActivityIndicatorViewStyle)style placeholderSize:(CGSize)size;
- (void)removeActivityIndicator;
- (UIActivityIndicatorView*)activityIndicator;
@end
