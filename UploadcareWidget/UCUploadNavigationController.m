//
//  UCUploadNavigationController.m
//  WidgetSample
//
//  Created by Zoreslav Khimich on 11/6/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UCUploadNavigationController.h"
#import "UCUploadViewController.h"
#import "UCGrabkitConfigurator.h"

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

#pragma mark - URL scheme handling related utilities
/* TODO: Move this elsewhere */

- (BOOL)schemeIsHandled:(NSString*)scheme {
    BOOL schemeHandlerExists;
    NSArray *bundleURLTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    for(NSDictionary *URLType in bundleURLTypes) {
        for(NSString *scheme in URLType[@"CFBundleURLSchemes"]) {
            if ([scheme isEqualToString:scheme]) {
                schemeHandlerExists = YES;
                break;
            }
        }
    }
    return schemeHandlerExists;
}

- (NSString *)genericScheme {
    return [[NSBundle mainBundle]bundleIdentifier];
}

- (BOOL)genericSchemeIsHandled {
    return [self schemeIsHandled:self.genericScheme];
}

#pragma mark - Services

- (void)enableFlickrWithAPIKey:(NSString *)flickrAPIKey flickrAPISecret:(NSString *)flickrAPISecret {
    if (!self.genericSchemeIsHandled) {
        /* FIXME: Better name and description */
        [NSException raise:@"URL Scheme not Registered" format:@"Please add '%@' to CFBundleURLSchemes", self.genericScheme];
    }
    [[UCGrabkitConfigurator shared] setFlickrRedirectUri:[[NSString stringWithFormat:@"%@://", self.genericScheme] lowercaseString]];
    [[UCGrabkitConfigurator shared] setFlickrApiKey:flickrAPIKey];
    [[UCGrabkitConfigurator shared] setFlickrApiSecret:flickrAPISecret];
    [[UCGrabkitConfigurator shared] setFlickrIsEnabled:YES];
}

@end