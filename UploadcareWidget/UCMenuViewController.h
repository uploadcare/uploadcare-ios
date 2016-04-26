//
//  UCMenuViewController.h
//  ExampleProject
//
//  Created by Yury Nechaev on 22.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UCMenuViewController : UIViewController


- (id)initWithProgress:(void(^)(NSUInteger bytesSent, NSUInteger bytesExpectedToSend))progress completion:(void(^)(NSString *fileId, NSError *error))completion;

- (void)presentFrom:(UIViewController *)controller;

@end
