//
//  UIImageView+Uploadcare.m
//  ExampleProject
//
//  Created by Yury Nechaev on 08.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UIImageView+Uploadcare.h"
#import <objc/runtime.h>

#define DEBUG_IMAGE_LOADER (1 && DEBUG)

static char kALGSessionDataTaskKey;

@implementation UIImageView (Uploadcare)

- (void)setDataTask:(NSURLSessionDataTask*)dataTask {
    objc_setAssociatedObject(self, &kALGSessionDataTaskKey, dataTask, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSURLSessionDataTask*)dataTask {
    return (NSURLSessionDataTask *)objc_getAssociatedObject(self, &kALGSessionDataTaskKey);
}

- (void)uc_setImageWithURL:(NSURL*)imageURL usingSession:(NSURLSession*)session {
    if (self.dataTask) {
        [self.dataTask cancel];
    }
    
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
                                               strongSelf.image = image;
                                           });
                                       } else {
#if (DEBUG_IMAGE_LOADER)
                                           NSLog(@"Couldn't load image at URL: %@", imageURL);
                                           NSLog(@"HTTP %ld", (long)httpResponse.statusCode);
#endif
                                       }
                                   }
                               }];
        [self.dataTask resume];
    }
    return;
}

@end
