//
//  UCAppDelegate.m
//  WidgetExample
//
//  Created by Zoreslav Khimich on 11/15/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UCAppDelegate.h"
#import "GRKConnectorsDispatcher.h"

@implementation UCAppDelegate

+ (BOOL)handleOpenURL:(NSURL *)url {
    return [[GRKConnectorsDispatcher sharedInstance] dispatchURLToConnectingServiceConnector:url];
}

+ (void)handleDidBecomeActive {
}

@end
