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

/**
 *  Progress block for all types of operations.
 *
 *  @param totalBytesSent           Contains number of bytes already sent to the receiver.
 *  @param totalBytesExpectedToSend Contains overall number of bytes needed to be sent.
 *  In a case if this value is unknown, NSUIntegerMax may be returned.
 */
typedef void (^UCProgressBlock)(NSUInteger totalBytesSent, NSUInteger totalBytesExpectedToSend);

/**
 *  Completion block for all types of operations.
 *
 *  @param response Response serialized value. May be nil.
 *  @param error    Error object which can contain API-dependent failure information,
 *  or come from Foundation issue, discovered during client request process.
 */
typedef void (^UCCompletionBlock)(id response, NSError *error);

/**
 *  Client layer class, which may be instantiated both as singleton:
 *  @code
 *  [UCClient defaultClient];
 *  @endcode
 *  or separate object:
 *  @code
 *  [UCClient new];
 *  @endcode
 *  Before use you should set Uploadcare public key to the client:
 *  @code
 *  [[UCClient defaultClient] setPublicKey:<#public key#>];
 *  @endcode
 */
@interface UCClient : NSObject

/**
 *  Uploadcare service public key for accessing uploading API.
 *  @see https://uploadcare.com/documentation/keys/
 */
@property (nonatomic, strong, readonly) NSString *publicKey;

/**
 *  NSCache instance which allows user to control cache size and
 *  clear it on demand.
 */
@property (nonatomic, strong, readonly) NSCache *cache;


+ (instancetype)defaultClient;

/**
 *  Use this method in order to obtain a session object if you want to use the same delegate flow
 *  for your tasks.
 *
 *  @return NSURLSession object instance.
 */
- (NSURLSession *)session;

/**
 *  Sets Uploadcare public key for client instance.
 *  This key is used in all requests and so required.
 *
 *  @param publicKey NSString containing public key for Uploadcare service.
 */
- (void)setPublicKey:(NSString *)publicKey;

/**
 *  Creates NSURLSessionDataTask object from provided api request and starts it.
 *
 *  @param ucRequest       API request object with corresponding data.
 *  @param progressBlock   @b UCProgressBlock handler for controlling progress flow.
 *  @param completionBlock @b UCCompletionBlock handler, invoked when task is complete.
 *
 *  @return NSURLSessionDataTask object.
 */
- (NSURLSessionDataTask *)performUCRequest:(UCAPIRequest *)ucRequest
                                  progress:(UCProgressBlock)progressBlock
                                completion:(UCCompletionBlock)completionBlock;

@end
