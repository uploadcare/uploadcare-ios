//
//  UploadcareKit.h
//  UploadcareKit
//
//  Created by Artyom Loenko on 8/1/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "UploadcareError.h" 


/**
 * @typedef Blocks of this type are called repeatedly during an operation to indicate the operation progress
 *
 * @param bytesDone   Number of bytes already transferred
 * @param bytesTotal  Number of total bytes expected to be transfered during the operation
 */
typedef void(^UploadcareProgressBlock)(long long bytesDone, long long bytesTotal);
/**
 * @typedef Blocks of this type are called once per succesfully completed operation
 *
 * @param uploadedFile    Object that describes the uploaded file
 */
typedef void(^UploadcareSuccessBlock)(NSString *fileId);
/**
 * @typedef Blocks of this type are called when an operation fails due to an error
 *
 * @param error   NSError object that contains the error code and description
 */
typedef void(^UploadcareFailureBlock)(NSError *error);

/**
 * This class provides access to Uploadcare API <http://uploadcare.com> */
@interface UploadcareKit : NSObject 

/** UploadcareKit shared instance */
+ (UploadcareKit *)shared;

/** Uploadcare public key */
@property (nonatomic) NSString* publicKey;

/** Deprecated, use startUploadingData:withName:contentType:store:progressBlock:successBlock:failureBlock: instead. */
- (void)uploadFileNamed:(NSString *)filename
            contentData:(NSData *)data
            contentType:(NSString *)contentTypeOrNil
          progressBlock:(UploadcareProgressBlock)progressBlock
           successBlock:(UploadcareSuccessBlock)successBlock
           failureBlock:(UploadcareFailureBlock)failureBlock
    __attribute__((deprecated));

/** Deprecated, use startUploadingFromURL:store:progressBlock:successBlock:failureBlock: instead. */
- (void)uploadFileFromURL:(NSString *)url
            progressBlock:(UploadcareProgressBlock)progressBlock
             successBlock:(UploadcareSuccessBlock)successBlock
             failureBlock:(UploadcareFailureBlock)failureBlock
    __attribute__((deprecated));


/** Start uploading a file.
 
 @param filename Destination file name.
 
 @param data Content of the file.
 
 @param contentTypeOrNil Internet media type of the file. If `nil`, the library will attempt to auto-detect content type using the file extension.
 
 @param shouldStore YES if the file should be automatically stored. Requires “automatic file storing” setting to be enabled https://uploadcare.com/accounts/settings/
 
 @param progressBlock The block to call repeatedly during the upload. Receives two arguments: **long long** `bytesDone` and **long long** `bytesTotal`.
 
 @param successBlock The handler block to call when the upload is completed succesfully. Receives a single string argument `fileId`.
 
 @param failureBlock The handler block to call when the upload fails due to an error. Receives a single argument NSError `*error`. */

- (NSOperation *)startUploadingData:(NSData *)data withName:(NSString *)filename contentType:(NSString *)contentTypeOrNil store:(BOOL)shouldStore progressBlock:(UploadcareProgressBlock)progressBlock successBlock:(UploadcareSuccessBlock)successBlock failureBlock:(UploadcareFailureBlock)failureBlock;

/** Start uploading a file found in a resource specified by a given URL.
 
    @param url The URL to retrieve the data from.
 
    @param shouldStore YES if the file should be automatically stored. Requires “automatic file storing” setting to be enabled https://uploadcare.com/accounts/settings/
 
    @param progressBlock The block to call repeatedly during the upload. Receives two arguments: **long long** `bytesDone` and **long long** `bytesTotal`.
 
    @param successBlock The handler block to call when the upload is completed succesfully. Receives a single string argument `fileId`.
 
    @param failureBlock The handler block to call when the upload fails due to an error. Receives a single argument NSError `*error`. */

- (NSOperation *)startUploadingFromURL:(NSURL *)url store:(BOOL)shouldStore progressBlock:(UploadcareProgressBlock)progressBlock successBlock:(UploadcareSuccessBlock)successBlock failureBlock:(UploadcareFailureBlock)failureBlock;

@end
