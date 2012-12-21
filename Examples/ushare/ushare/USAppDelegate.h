//
//  USAppDelegate.h
//  ushare
//
//  Created by Zoreslav Khimich on 12/9/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>

@class USViewController;

@interface USAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) USViewController *viewController;

@end
