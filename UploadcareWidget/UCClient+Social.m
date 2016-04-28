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
    if ([components.scheme isEqualToString:[@"uploadcare" stringByAppendingString:self.publicKey]]) {
        if ([components.path.pathComponents.lastObject isEqualToString:@"fail"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:UCURLSchemeDidReceiveFailureCallbackNotification object:url];
        } else if ([components.path.pathComponents.lastObject isEqualToString:@"success"]) {
            [self storeCookiesFromComponents:components];
            [[NSNotificationCenter defaultCenter] postNotificationName:UCURLSchemeDidReceiveSuccessCallbackNotification object:url];
        }
        return YES;
    } else {
        return NO;
    }
}

- (void)storeCookiesFromComponents:(NSURLComponents *)components {
    for (NSURLQueryItem *item in components.queryItems) {
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 [components host], NSHTTPCookieDomain,
                                 [components path], NSHTTPCookiePath,
                                 item.name,  NSHTTPCookieName,
                                 item.value, NSHTTPCookieValue,
                                 nil]];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];;
    }
    
}

@end
