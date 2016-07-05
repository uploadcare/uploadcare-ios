//
//  AppDelegate.m
//  ExampleProject
//
//  Created by Yury Nechaev on 05.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "AppDelegate.h"
#import "Uploadcare.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Replace demopublickey with your key
    [[UCClient defaultClient] setPublicKey:@"demopublickey"];
    return YES;
}

// IOS 9
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    NSLog(@"URL OPEN: %@", url);
    return [[UCClient defaultClient] handleURL:url];
}

// IOS 8
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"URL OPEN: %@", url);
    return [[UCClient defaultClient] handleURL:url];
}

@end
