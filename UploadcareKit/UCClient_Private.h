//
//  UCClient_Private.h
//  ExampleProject
//
//  Created by Yury Nechaev on 05.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCClient.h"

@interface UCClient ()

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request data:(NSData *)data;

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                                   completion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;

- (void)launchTask:(NSURLSessionDataTask *)task
          progress:(UCProgressBlock)progress
        completion:(UCCompletionBlock)completion;

@end
