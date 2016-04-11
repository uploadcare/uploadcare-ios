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

NSString *const USSLoginAddressKey = @"login_link";

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

@end
