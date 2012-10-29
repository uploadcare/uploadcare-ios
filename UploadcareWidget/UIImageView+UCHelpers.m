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
        NSLog(@"resizing from %.1f %.1f", sourceImage.size.width, sourceImage.size.height);
        return [sourceImage imageByScalingToSize:size];
    } successBlock:successBlock failureBlock:failureBlock];
}

- (void)showActivityIndicatorWithStyle:(UIActivityIndicatorViewStyle)style placeholderSize:(CGSize)size {
    [self setImage:[UIImage blankImageWithSize:size]];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:style];
    indicator.tag = kUCImageViewActivityIndicatorViewTag;
    indicator.center = CGPointMake(size.width / 2, size.height / 2);
    [self addSubview:indicator];
    [indicator startAnimating];
}

- (void)removeActivityIndicator {
    UIView *allegedIndicator = [self viewWithTag:kUCImageViewActivityIndicatorViewTag];
    if ([allegedIndicator isKindOfClass:[UIActivityIndicatorView class]]) { /* just to be on the safe side */
        [allegedIndicator removeFromSuperview];
    }
}

@end


