//
//  UploadcareKit.m
//  UploadcareKit
//
//  Created by Artyom Loenko on 8/1/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UploadcareKit.h"
#import "UploadcareStatusWatcher.h"
/* !!!! */
//#import "UploadcareKit+Deprecated.h"
/* !!!! */

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

#import "AFJSONRequestOperation.h"
#import "AFHTTPRequestOperation.h"
#import "UIImageView+AFNetworking.h"

#import "JSONKit.h"

/* GHETTO */

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s:%d " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

#define ALog(fmt, ...) NSLog((@"%s:%d " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#define API_BASE @"https://api.staging0.uploadcare.com"
#define API_UPLOAD @"https://upload.staging0.uploadcare.com"
#define API_RESIZER @"https://services.staging0.uploadcare.com/resizer/"
#define REQUEST_TIMEOUT 20.0

#define DATE_RFC2822_FORMAT @"EEE, dd MMM yyyy HH:mm:ss Z"

/* -GHETTO */

NSString * const UploadcareURLUpload = API_UPLOAD;

@interface UploadcareKit () {
    NSString *_secretKey;
}
- (NSURLRequest *)buildRequestWithMethod:(NSString *)method baseURL:(NSString *)base_url URI:(NSString *)url;
- (NSURLRequest *)buildRequestWithMethod:(NSString *)method baseURL:(NSString *)base_url URI:(NSString *)url andData:(NSString *)data;
- (NSURLRequest *)buildRequestForUploadWithFilename:(NSString *)filename andData:(NSData *)data;

+ (NSString *)md5ForString:(NSString *)input;
+ (NSString *)hashedValueForString:(NSString *)input WithKey:(NSString *) key;
+ (NSString *)validateUUID:(NSString *)uuid;
@end

@implementation UploadcareKit

- (NSString *)publicKey {
    if (!_publicKey) {
        /* TODO: Provide some details re. where to get one */
        [NSException raise:UploadcareMissingPublicKeyException format:@"You must provide the public key"];
    }
    
    return _publicKey;
}

+ (id)shared
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
        //TODO: Move this -> init
        [UploadcareStatusWatcher preheatPusher];
        [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObjects:@"application/vnd.uploadcare-v0.2+json", nil]];
    });
    return _sharedObject;
}
         
#pragma mark - Kit Actions

- (void)uploadFileWithName:(NSString *)filename
                      data:(NSData *)data
             progressBlock:(UploadcareProgressBlock)progressBlock
              successBlock:(UploadcareSuccessBlock)successBlock
              failureBlock:(UploadcareFailureBlock)failureBlock {

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:[self buildRequestForUploadWithFilename:filename andData:data]];
    [operation setUploadProgressBlock:^(NSInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        progressBlock(totalBytesWritten, totalBytesExpectedToWrite);
    }];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        JSONDecoder* decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
        NSDictionary *uuid = [decoder objectWithData:responseObject];
        NSLog(@"JSON --- %@", uuid);
        UploadcareFile *file = [UploadcareFile new];
        file.info = @{@"file_id" : uuid[@"myfile"], @"original_filename" : filename };
        successBlock(file);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"!failure %@ : %@", [operation response], error);
        failureBlock(error);
    }];
    [operation start];
}

- (void)uploadFileFromURL:(NSString *)url
            progressBlock:(UploadcareProgressBlock)progressBlock
             successBlock:(UploadcareSuccessBlock)successBlock
             failureBlock:(UploadcareFailureBlock)failureBlock {
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:[self buildRequestWithMethod:@"GET"
                                                          baseURL:API_UPLOAD
                                                              URI:[NSString stringWithFormat:@"/from_url/?pub_key=%@&source_url=%@", self.publicKey, url]]
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         DLog(@"+success %@ : %@ : %@", response, [request URL], JSON);
         NSString *token = JSON[@"token"];
         [UploadcareStatusWatcher watchUploadWithToken:token progressBlock:progressBlock successBlock:successBlock failureBlock:failureBlock];
     }
     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         DLog(@"!failure %@ : %@ : %@", response, [request URL], JSON);
         failureBlock(error);
     }];
    [operation start];
}

@end
