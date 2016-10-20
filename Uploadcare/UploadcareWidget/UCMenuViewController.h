//
//  UCMenuViewController.h
//  ExampleProject
//
//  Created by Yury Nechaev on 22.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UCWidgetVC.h"

@interface UCMenuViewController : UIViewController

- (id)initWithProgress:(UCProgressBlock)progress completion:(UCWidgetCompletionBlock)completion;

- (void)presentFrom:(UIViewController *)controller;

@end
