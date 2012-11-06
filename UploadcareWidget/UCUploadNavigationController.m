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
@property UCUploadViewController *uploadViewController;
@end

@implementation UCUploadNavigationController

- (id)init {
    self.uploadViewController = nil;//[[UCUploadViewController alloc]init];
    return [super initWithRootViewController:_uploadViewController];
}

- (void)setTitle:(NSString *)title {
    self.uploadViewController.title = title;
}

- (NSString*)title {
    return self.uploadViewController.title;
}

@end
