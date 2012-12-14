//
//  UCUploadNavigationController.m
//  WidgetSample
//
//  Created by Zoreslav Khimich on 11/6/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UCWidget.h"
#import "UCUploadViewController.h"
#import "UCGrabkitConfigurator.h"

@interface UCWidget () {
    id<UINavigationControllerDelegate,UCWidgetDelegate> _delegate;
}

@property (strong) UCUploadViewController *uploadViewController;
@end

NSString *const UCFacebookMisconfigurationException = @"UCFacebookConfiguratioException";
NSString *const UCGenericURLSchemaNotConfiguredException = @"UCGenericURLSchemaNotConfiguredException";

@implementation UCWidget

- (id)initWithUploadcarePublicKey:(NSString *)publicKey {
    self = [super init];
    if (self) {
        _uploadViewController = [[UCUploadViewController alloc]initWithWidget:self];
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

- (BOOL)schemeIsHandled:(NSString*)targetScheme {
    BOOL schemeHandlerExists = NO;
    NSArray *bundleURLTypes = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    for(NSDictionary *URLType in bundleURLTypes) {
        for(NSString *scheme in URLType[@"CFBundleURLSchemes"]) {
            if ([scheme isEqualToString:targetScheme]) {
                schemeHandlerExists = YES;
                break;
            }
        }
    }
    return schemeHandlerExists;
}

- (NSString *)genericScheme {
    return  [NSString stringWithFormat:@"uc-%@", [[[NSBundle mainBundle]bundleIdentifier]stringByReplacingOccurrencesOfString:@"." withString:@"-"]];
}

- (void)assertGenericSchemeHandled {
    if (![self schemeIsHandled:self.genericScheme]) {
        /* FIXME: Better name and description */
        [NSException raise:UCGenericURLSchemaNotConfiguredException format:@"Please add '%@' to CFBundleURLSchemes in app's Info.plist", self.genericScheme];
    }
}

#pragma mark - Services

- (void)enableFacebook {
    NSString *facebookId = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"FacebookAppID"];
    if (!facebookId) {
        [NSException raise:UCFacebookMisconfigurationException format:@"Please add FacebookAppID property to the Info.plist (see 'Adding your Facebook App ID' section of https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/3.1/ )"];
    }
    NSString *facebookScheme = [NSString stringWithFormat:@"fb%@", facebookId];
    if (![self schemeIsHandled:facebookScheme]) {
        [NSException raise:UCFacebookMisconfigurationException format:@"Please add '%@' to CFBundleURLSchemes in app's Info.plist (see 'Adding your Facebook App ID' section of https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/3.1/ )", facebookScheme];
    }
    
    UCGrabkitConfigurator *config = [UCGrabkitConfigurator shared];
    [config setFacebookAppId:facebookId];
    [config setFacebookIsEnabled:YES];
}

- (void)enableFlickrWithAPIKey:(NSString *)flickrAPIKey flickrAPISecret:(NSString *)flickrAPISecret {
    [self assertGenericSchemeHandled];
    UCGrabkitConfigurator *config = [UCGrabkitConfigurator shared];
    [config setFlickrRedirectUri:[[NSString stringWithFormat:@"%@://", self.genericScheme] lowercaseString]];
    [config setFlickrApiKey:flickrAPIKey];
    [config setFlickrApiSecret:flickrAPISecret];
    [config setFlickrIsEnabled:YES];
}

- (void)enableInstagramWithClientId:(NSString *)instagramAppId {
    [self assertGenericSchemeHandled];
    UCGrabkitConfigurator *config = [UCGrabkitConfigurator shared];
    [config setInstagramRedirectUri:[[NSString stringWithFormat:@"%@://", self.genericScheme] lowercaseString]];
    [config setInstagramAppId:instagramAppId];
    [config setInstagramIsEnabled:YES];
}

- (void)setDelegate:(id<UINavigationControllerDelegate,UCWidgetDelegate>)delegate {
    [super setDelegate:delegate];
    _delegate = delegate;
}
- (id<UINavigationControllerDelegate,UCWidgetDelegate>)delegate {
    return _delegate;
}

@end