//
//  UIImageView+Uploadcare.h
//  ExampleProject
//
//  Created by Yury Nechaev on 08.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Uploadcare)

/**
 *  Performs background image download operation in the provided session. Uses provided cache
 *  to store already loaded images.
 *
 *  @param imageURL Image url address.
 *  @param session  NSURLSession reference, where NSURLSessionDataTask will be created and managed by.
 *  @param cache	NSCache reference.
 */
- (void)uc_setImageWithURL:(NSURL*)imageURL usingSession:(NSURLSession*)session cache:(NSCache *)cache;

@end
