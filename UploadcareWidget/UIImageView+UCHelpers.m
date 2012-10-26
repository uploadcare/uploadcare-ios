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

@implementation UIImageView (UCHelpers)

- (void)setImageFromURL:(NSURL *)url imageProcessingBlock:(UIImage *(^)(UIImage *image))imageProcessingBlock {
    assert(url != nil);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setHTTPShouldHandleCookies:NO];
    [request setHTTPShouldUsePipelining:YES];
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request imageProcessingBlock:imageProcessingBlock success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        self.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"%s failed to retrieve image from `%@` (%d): %@", __PRETTY_FUNCTION__, request.URL, response.statusCode, error);
    }];
    [operation start];
}

- (void)setImageFromURL:(NSURL *)url scaledToSize:(CGSize)size {
    [self setImageFromURL:url imageProcessingBlock:^UIImage *(UIImage *sourceImage) {
        NSLog(@"resizing from %.1f %.1f", sourceImage.size.width, sourceImage.size.height);
        return [sourceImage imageByScalingToSize:size];
    }];
}

@end
