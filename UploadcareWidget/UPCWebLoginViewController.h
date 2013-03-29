//
//  UPCWebViewController.h
//  Social Source
//
//  Created by Zoreslav Khimich on 01/03/2013.
//  Copyright (c) 2013 zrxq. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UPCWebLoginViewLoadedURLBlock)(NSURL *URL);

@interface UPCWebLoginViewController : UIViewController<UIWebViewDelegate>

- (UIWebView *)webView;

- (void)loadURL:(NSURL *)url URLLoadedBlock:(UPCWebLoginViewLoadedURLBlock)URLLoadedBlock;

@end
