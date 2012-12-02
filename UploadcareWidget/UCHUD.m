//
//  UCHUD.m
//  WidgetExample
//
//  Created by Zoreslav Khimich on 11/7/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UCHUD.h"
#import "MBProgressHUD.h"

@implementation UCHUD

+ (MBProgressHUD *)sharedHUD {
    static MBProgressHUD *_sharedHUD;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        _sharedHUD = [[MBProgressHUD alloc] initWithView:rootView];
        [rootView addSubview:_sharedHUD];
        
        _sharedHUD.userInteractionEnabled = NO;
        _sharedHUD.mode = MBProgressHUDModeAnnularDeterminate;
        _sharedHUD.animationType = MBProgressHUDAnimationZoom;
    });
    return _sharedHUD;
}

+ (void)show {
    [[self sharedHUD]show:YES];
}

+ (void)dismiss {
    [[self sharedHUD]hide:YES];
}

+ (void)setProgress:(CGFloat)progress {
    [[self sharedHUD]setProgress:progress];
    
}

+ (void)setText:(NSString *)text {
    [[self sharedHUD] setLabelText:text];
}


@end
