//
//  UCAppDelegate.h
//  WidgetExample
//
//  Created by Zoreslav Khimich on 11/15/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCAppDelegate : NSObject

+ (BOOL)handleOpenURL:(NSURL *)url;
+ (void)handleDidBecomeActive;

@end
