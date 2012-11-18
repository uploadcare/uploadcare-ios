//
//  AppDelegate.m
//  WidgetExample
//
//  Created by Artyom Loenko on 8/3/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"

#import <UploadcareWidget.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.

    MasterViewController *masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [UCAppDelegate handleDidBecomeActive];
    
    /* TODO: Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface. */
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	
    if ([UCAppDelegate handleOpenURL:url]) {
        return YES;
    }
    
    /* TODO: Add your own URL handling code (if needed) */
    
    return NO;
}


@end
