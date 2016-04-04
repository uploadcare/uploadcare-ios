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


@protocol UCMultipartFormDataProtocol <NSObject>

- (void)appendPartWithFileData:(NSData *)data
                          name:(NSString *)name
                      fileName:(NSString *)fileName
                      mimeType:(NSString *)mimeType;

- (void)appendPartWithValue:(NSString *)value
                       name:(NSString *)name;

- (void)appendPartWithPayload:(UCAPIRequestPayload *)payload;

@end

@interface UCMultipartFormData : NSObject <UCMultipartFormDataProtocol>

@property (nonatomic, strong) NSString *boundary;

- (NSUInteger)contentLength;
- (NSData *)bodyByFinalizingMultipartData;

@end


typedef void (^UCProgressBlock)(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend);

typedef void (^UCCompletionBlock)(id response, NSError *error);


@interface UCClient : NSObject

+ (instancetype)defaultClient;

- (void)setPublicKey:(NSString *)publicKey;

- (NSURLSessionDataTask *)performUCRequest:(UCAPIRequest *)ucRequest
                                  progress:(UCProgressBlock)progressBlock
                                completion:(UCCompletionBlock)completionBlock;

@end
