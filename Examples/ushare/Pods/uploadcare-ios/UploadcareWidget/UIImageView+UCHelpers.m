//
//  UIImageView+UCHelpers.m
//  WidgetExample
//
//  Created by Zoreslav Khimich on 10/24/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UIImageView+UCHelpers.h"
#import "UIImage+UCHelpers.h"
#import "AFImageRequestOperation.h"

static const NSInteger kUCImageViewActivityIndicatorViewTag = 10812; // Random

@implementation UIImageView (UCHelpers)

- (void)setImageFromURL:(NSURL *)url imageProcessingBlock:(UIImage *(^)(UIImage *image))imageProcessingBlock successBlock:(void (^)(UIImage *))successBlock failureBlock:(void (^)(NSError *))failureBlock {
    assert(url != nil);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setHTTPShouldHandleCookies:NO];
    [request setHTTPShouldUsePipelining:YES];
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request imageProcessingBlock:imageProcessingBlock success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        self.image = image;
        if (successBlock) successBlock(self.image);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"%s failed to retrieve image from `%@` (%d): %@", __PRETTY_FUNCTION__, request.URL, response.statusCode, error);
        if (failureBlock) failureBlock(error);
    }];
    [operation start];
}

- (void)setImageFromURL:(NSURL *)url scaledToSize:(CGSize)size successBlock:(void (^)(UIImage *))successBlock failureBlock:(void (^)(NSError *))failureBlock {
    [self setImageFromURL:url imageProcessingBlock:^UIImage *(UIImage *sourceImage) {
        return [sourceImage imageByScalingToSize:size];
    } successBlock:successBlock failureBlock:failureBlock];
}

- (void)setImageFromURL:(NSURL *)url scaledToSize:(CGSize)size placeholderImage:(UIImage *)placeholderImage showActivityIndicator:(BOOL)showIndicator withStyle:(UIActivityIndicatorViewStyle)style {
    if (!placeholderImage) {
        placeholderImage = [UIImage blankImageWithSize:size];
    }
    [self setImage:placeholderImage];
    UIActivityIndicatorView *indicator;
    if (showIndicator) {
        indicator = [self showActivityIndicatorWithStyle:style center:CGPointMake(placeholderImage.size.width / 2, placeholderImage.size.height / 2)];
    }
    [self setImageFromURL:url scaledToSize:size successBlock:^(UIImage *image) {
        /* success */
        [indicator removeFromSuperview];
    } failureBlock:^(NSError *error) {
        /* failure */
        [indicator removeFromSuperview];
        /* TODO: show failure image placeholder? */
    }];
}

- (UIActivityIndicatorView*)activityIndicator {
    UIView *allegedIndicator = [self viewWithTag:kUCImageViewActivityIndicatorViewTag];
    if ([allegedIndicator isKindOfClass:[UIActivityIndicatorView class]]) {
        return (UIActivityIndicatorView*)allegedIndicator;
    }
    return nil;
}

- (UIActivityIndicatorView *)showActivityIndicatorWithStyle:(UIActivityIndicatorViewStyle)style center:(CGPoint)center {
    UIActivityIndicatorView *indicator;
    if ((indicator = self.activityIndicator)) return indicator; // already exists, one is enough
    indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:style];
    indicator.tag = kUCImageViewActivityIndicatorViewTag;
    indicator.center = center;
    [self addSubview:indicator];
    [indicator startAnimating];
    return indicator;
}

- (UIActivityIndicatorView *)showActivityIndicatorWithStyle:(UIActivityIndicatorViewStyle)style placeholderSize:(CGSize)size {
    [self setImage:[UIImage blankImageWithSize:size]];
    return [self showActivityIndicatorWithStyle:style center:CGPointMake(size.width / 2, size.height / 2)];
}

- (void)removeActivityIndicator {
    [self.activityIndicator removeFromSuperview];
}

@end


