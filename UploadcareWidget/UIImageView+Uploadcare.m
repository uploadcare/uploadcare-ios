//
//  UIImageView+Uploadcare.m
//  ExampleProject
//
//  Created by Yury Nechaev on 08.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UIImageView+Uploadcare.h"
#import "UCClient.h"
#import <objc/runtime.h>

#define DEBUG_IMAGE_LOADER (1 && DEBUG)

static char kUCSessionDataTaskKey;

@implementation UIImageView (Uploadcare)

- (void)setDataTask:(NSURLSessionDataTask*)dataTask {
    objc_setAssociatedObject(self, &kUCSessionDataTaskKey, dataTask, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSURLSessionDataTask*)dataTask {
    return (NSURLSessionDataTask *)objc_getAssociatedObject(self, &kUCSessionDataTaskKey);
}

- (void)uc_setImageWithURL:(NSURL*)imageURL usingSession:(NSURLSession*)session cache:(NSCache *)cache {
    [self uc_setImageWithURL:imageURL usingSession:session cache:cache animated:YES];
}

- (void)uc_setImageWithURL:(NSURL*)imageURL usingSession:(NSURLSession*)session cache:(NSCache *)cache animated:(BOOL)animated {
    if (self.dataTask) {
        [self.dataTask cancel];
    }
    
    __block NSCache *blockCache = cache;
    UIImage *storedImage = [blockCache objectForKey:imageURL.absoluteString];
    if (storedImage) {
        [self.layer removeAllAnimations];
        self.image = storedImage;
    } else {
        if (imageURL) {
            __weak typeof(self) weakSelf = self;
            self.dataTask = [session dataTaskWithURL:imageURL
                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                       __strong __typeof(weakSelf) strongSelf = weakSelf;
                                       if (error) {
#if (DEBUG_IMAGE_LOADER)
                                           NSLog(@"ERROR: %@", error);
#endif
                                       }
                                       else {
                                           NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
                                           if (200 == httpResponse.statusCode) {
                                               UIImage * image = [UIImage imageWithData:data];
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   if (animated) {
                                                       [strongSelf setAlpha:0.0];
                                                       strongSelf.image = image;
                                                       [strongSelf.layer removeAllAnimations];
                                                       [UIView animateWithDuration:0.3 animations:^{
                                                           [self setAlpha:1.0];
                                                       }];
                                                   } else {
                                                       strongSelf.image = image;
                                                   }
                                                   [blockCache setObject:image forKey:imageURL.absoluteString];
                                               });
                                           } else {
#if (DEBUG_IMAGE_LOADER)
                                               NSLog(@"Failed to load image URL: %@", imageURL);
                                               NSLog(@"HTTP CODE %ld", (long)httpResponse.statusCode);
#endif
                                           }
                                       }
                                   }];
            [self.dataTask resume];
        }
    }
    return;

}

@end
