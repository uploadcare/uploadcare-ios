//
//  UCUploadNavigationController.m
//  WidgetSample
//
//  Created by Zoreslav Khimich on 11/6/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UCUploadNavigationController.h"
#import "UCUploadViewController.h"

@interface UCUploadNavigationController ()
@property (strong) UCUploadViewController *uploadViewController;
@end

@implementation UCUploadNavigationController

- (id)initWithUploadcarePublicKey:(NSString *)publicKey {
    self = [super init];
    if (self) {
        _uploadViewController = [[UCUploadViewController alloc]init];
        [[UploadcareKit shared]setPublicKey:publicKey];
        self.viewControllers = @[_uploadViewController];
    }
    return self;
}

#pragma mark - forwarding bussiness

- (void)setUploadCompletionBlock:(UploadcareSuccessBlock)completionBlock {
    [self.uploadViewController setUploadCompletionBlock:completionBlock];
}

- (void)setUploadFailureBlock:(UploadcareFailureBlock)failureBlock {
    [self.uploadViewController setUploadFailureBlock:failureBlock];
}

@end