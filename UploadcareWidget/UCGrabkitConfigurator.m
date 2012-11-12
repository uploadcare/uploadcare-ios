//
//  UCGrabkitConfigurator.m
//  WidgetExample
//
//  Created by Zoreslav Khimich on 11/12/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UCGrabkitConfigurator.h"

@implementation UCGrabkitConfigurator

+ (id)shared {
    static UCGrabkitConfigurator *_shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[UCGrabkitConfigurator alloc]init];
    });
    return _shared;
}

@end
