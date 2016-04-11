//
//  UCClient.h
//  Riders
//
//  Created by Yury Nechaev on 31.03.16.
//  Copyright © 2016 Whitescape. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UCAPIRequest;
@class UCAPIRequestPayload;

typedef void (^UCProgressBlock)(NSUInteger totalBytesSent, NSUInteger totalBytesExpectedToSend);
typedef void (^UCCompletionBlock)(id response, NSError *error);

@interface UCClient : NSObject

@property (nonatomic, strong, readonly) NSString *publicKey;
@property (nonatomic, strong, readonly) NSCache *cache;

+ (instancetype)defaultClient;

- (NSURLSession *)session;

- (void)setPublicKey:(NSString *)publicKey;

- (NSURLSessionDataTask *)performUCRequest:(UCAPIRequest *)ucRequest
                                  progress:(UCProgressBlock)progressBlock
                                completion:(UCCompletionBlock)completionBlock;

@end
