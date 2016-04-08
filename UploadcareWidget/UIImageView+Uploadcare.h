//
//  UIImageView+Uploadcare.h
//  ExampleProject
//
//  Created by Yury Nechaev on 08.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Uploadcare)

- (void)uc_setImageWithURL:(NSURL*)imageURL usingSession:(NSURLSession*)session cache:(NSCache *)cache;

@end
