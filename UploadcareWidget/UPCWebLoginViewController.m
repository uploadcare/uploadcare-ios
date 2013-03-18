//
//  UPCWebViewController.m
//  Social Source
//
//  Created by Zoreslav Khimich on 01/03/2013.
//  Copyright (c) 2013 zrxq. All rights reserved.
//

#import "UPCWebLoginViewController.h"

@interface UPCWebLoginViewController ()

@property (strong) UPCWebLoginViewLoadedURLBlock URLLoadedBlock;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation UPCWebLoginViewController

- (void)loadView {
    UIWebView *webView =  [[UIWebView alloc]init];
    [webView setDelegate:self];
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.view = webView;
}

- (void)viewDidAppear:(BOOL)animated {
    self.parentViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.activityIndicator];    
}

- (void)viewDidDisappear:(BOOL)animated {
    self.parentViewController.navigationItem.rightBarButtonItem = nil;
}

- (UIWebView *)webView {
    return (UIWebView *)self.view;
}

- (UIActivityIndicatorView *)activityIndicator {
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.hidesWhenStopped = YES;
    }
    return _activityIndicator;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    /* Install and show the spinner */
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
    
    if (self.URLLoadedBlock) {
        self.URLLoadedBlock(webView.request.URL);
    }
}

- (void)loadURL:(NSURL *)url URLLoadedBlock:(UPCWebLoginViewLoadedURLBlock)URLLoadedBlock {
    self.URLLoadedBlock = URLLoadedBlock;
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

@end
