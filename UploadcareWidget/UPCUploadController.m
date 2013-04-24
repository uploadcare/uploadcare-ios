//
//  UPCUploadController.m
//  WidgetSample
//
//  Created by Zoreslav Khimich on 11/6/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UPCUploadController.h"
#import "UPCWidgetMenuViewController.h"

@interface UPCUploadController ()

@property (strong, nonatomic) UPCWidgetMenuViewController *menuController;

@end

@implementation UPCUploadController

- (id)initWithUploadcarePublicKey:(NSString *)publicKey {
    self = [super init];
    if (self) {
        _menuController = [[UPCWidgetMenuViewController alloc]initWithUploadcarePublicKey:publicKey];
        self.viewControllers = @[_menuController];
    }
    return self;
}

#pragma mark - Appearance

+ (void)load {
    /* navigation bar appearance */
    id navbarProxy = [UINavigationBar appearanceWhenContainedIn:[UPCUploadController class], nil];
    [navbarProxy setBackgroundImage:[UIImage imageNamed:@"UPCNavBar"] forBarMetrics:UIBarMetricsDefault];
    
    if ([navbarProxy respondsToSelector:@selector(setShadowImage:)])
        [navbarProxy setShadowImage:[[UIImage alloc] init]];

    [navbarProxy setTitleTextAttributes:@{UITextAttributeTextColor : [UIColor colorWithRed:107./255 green:112./255 blue:115./255 alpha:1.], UITextAttributeTextShadowColor:[UIColor colorWithWhite:1. alpha:0.7], UITextAttributeTextShadowOffset:[NSValue valueWithUIOffset:UIOffsetMake(0, 1)]}];
    [navbarProxy setTintColor:[UIColor colorWithRed:151./255 green:155./255 blue:159./255 alpha:1.]];
        
    /* table cells */
    id tableCellProxy = [UITableViewCell appearanceWhenContainedIn:[UPCUploadController class], nil];
    [tableCellProxy setSelectionStyle:UITableViewCellSelectionStyleGray];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self popToRootViewControllerAnimated:NO];
}

@end