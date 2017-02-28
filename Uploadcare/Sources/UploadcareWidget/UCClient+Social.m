//
//  UCClient+Social.m
//  ExampleProject
//
//  Created by Yury Nechaev on 05.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCClient+Social.h"
#import "UCSocialRequest.h"
#import "UCClient_Private.h"
#import "UCSocialConstantsHeader.h"
#import "UCConstantsHeader.h"

NSString *const USSPublicKeyHeader = @"X-Uploadcare-PublicKey";
NSString *const UCAcceptHeader = @"Accept";
NSString *const USSContentType = @"application/vnd.ucare.ss-v0.1+json";

@implementation UCClient (Social)

- (NSURLSessionDataTask *)performUCSocialRequest:(UCSocialRequest *)ucSocialRequest
                                      completion:(UCCompletionBlock)completionBlock {
    NSURLSessionDataTask *task = nil;
    
    if ([ucSocialRequest isKindOfClass:[UCSocialRequest class]]) {
        
        [self authorizeSocialRequest:ucSocialRequest];
        
        NSMutableURLRequest *urlRequest = [ucSocialRequest request];
        
        task = [self dataTaskWithRequest:urlRequest completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        }];
        
        [self launchTask:task progress:nil completion:completionBlock];
    }
    
    return task;
}

- (void)authorizeSocialRequest:(UCSocialRequest *)request {
    request.headers = @{UCAcceptHeader:USSContentType,
                        USSPublicKeyHeader:self.publicKey};
}

+ (NSString *)socialErrorDomain {
    return [@[UCSocialErrorDomain, UCRemoteFileUploadDomain] componentsJoinedByString:@"."];
}

- (BOOL)handleURL:(NSURL *)url {
    if (!self.publicKey) return NO;
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    if ([components.scheme isEqualToString:[@"uc-" stringByAppendingString:self.publicKey]]) {
        if ([components.path.pathComponents.lastObject isEqualToString:@"success"]) {
            [self storeCookiesFromComponents:components];
            [[NSNotificationCenter defaultCenter] postNotificationName:UCURLSchemeDidReceiveSuccessCallbackNotification object:url];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:UCURLSchemeDidReceiveFailureCallbackNotification object:url];
        }
        return YES;
    } else {
        return NO;
    }
}

- (void)storeCookiesFromComponents:(NSURLComponents *)components {
    for (NSURLQueryItem *item in components.queryItems) {
        [self storeCookieWithHost:components.host name:item.name value:item.value];
    }
}

- (void)storeCookieWithHost:(NSString *)host name:(NSString *)name value:(NSString *)value {
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.year = 1; // Default expire time is 1 year
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    NSDate *nextDate = [theCalendar dateByAddingComponents:dayComponent toDate:[NSDate date] options:0];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:
                            @{
                              NSHTTPCookieDomain   : UCSocialAPIRoot,
                              NSHTTPCookiePath     : [NSString stringWithFormat:@"/%@/", host],
                              NSHTTPCookieName     : name,
                              NSHTTPCookieValue    : value,
                              NSHTTPCookieExpires  : nextDate
                              }];

    // `setCookie` method doesn't override the existing cookie which was created by Safari, so we have to delete it manually first and set new after that
    NSHTTPCookie *cookieToDelete;
    for (NSHTTPCookie *c in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        if ([c.path isEqualToString:cookie.path] && [c.domain isEqualToString:cookie.domain] && [c.name isEqualToString:cookie.name]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:c];
            break;
        }
    }

    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
}

@end
