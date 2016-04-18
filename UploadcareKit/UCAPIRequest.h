//
//  UCAPIRequest.h
//  Riders
//
//  Created by Yury Nechaev on 31.03.16.
//  Copyright © 2016 Whitescape. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UCAPIRequestPayload;

/**
 *  Base API request class which contains all necessary data for NSURLSession.
 *  Use this class for subclassing only.
 */
@interface UCAPIRequest : NSObject
@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) UCAPIRequestPayload *payload;

- (NSMutableURLRequest *)request;

@end

/**
 *  UCAPIRequestPayload is used for multipart/form-data requests and contains
 *  all necessary values for it's construction.
 */
@interface UCAPIRequestPayload : NSObject
@property (nonatomic, strong, readonly) NSData *payload;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *fileName;
@property (nonatomic, strong, readonly) NSString *mimeType;

+ (instancetype) payloadWithData:(NSData *)payload name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType;

@end
