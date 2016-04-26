//
//  UCWebViewController.m
//  ExampleProject
//
//  Created by Yury Nechaev on 06.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCWebViewController.h"

@interface UCWebViewController () <UIWebViewDelegate>
@property (nonatomic, copy) void (^cancelBlock)();
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSURL *url;
@end

@implementation UCWebViewController

- (id)initWithURL:(NSURL *)url cancelBlock:(void(^)())cancelBlock {
    self = [super init];
    if (self) {
        _url = url;
        _cancelBlock = cancelBlock;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView = [[UIWebView alloc] init];
    [self.view addSubview:self.webView];
    
    NSDictionary *views = @{@"webView":self.webView};
    
    [self.webView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSArray *horizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|" options:0 metrics:nil views:views];
    NSArray *vertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webView]|" options:0 metrics:nil views:views];
    
    [self.view addConstraints:horizontal];
    [self.view addConstraints:vertical];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(close)];
    self.navigationItem.rightBarButtonItem = cancelButton;
}

- (void)close {
    if (self.cancelBlock) self.cancelBlock();
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
