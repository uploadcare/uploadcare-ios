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
+ (id)shared;

/** Uploadcare public key */
@property (nonatomic) NSString* publicKey;

/**
 Uploads an arbitrary file (e.g. an image, a movie clip, a spreadsheet document, etc.)
 
 @param filename            The file name to assign to the file uploaded.
 @param data                The data to upload.
 @param contentTypeOrNil    The Internet media type of the file. If `nil`, the type will be guessed from the file extension.
 @param progressBlock       The block to call repeatedly during the upload. Receives two arguments: **long long** `bytesDone` and **long long** `bytesTotal`.
 @param successBlock        The handler block to call when the upload is completed succesfully. Receives a single string argument `fileId`.
 @param failureBlock        The handler block to call when the upload fails due to an error. Receives a single argument NSError `*error`
*/
- (void)uploadFileNamed:(NSString *)filename
            contentData:(NSData *)data
            contentType:(NSString *)contentTypeOrNil
          progressBlock:(UploadcareProgressBlock)progressBlock
           successBlock:(UploadcareSuccessBlock)successBlock
           failureBlock:(UploadcareFailureBlock)failureBlock;

/**
 Makes Uploadcare service upload a file from web
 
 @param url             The URL to retrieve the file from.
 @param progressBlock   The block to call repeatedly during the upload. Receives two arguments: **long long** `bytesDone` and **long long** `bytesTotal`.
 @param successBlock    The handler block to call when the upload is completed succesfully. Receives a single string argument `fileId`.
 @param failureBlock    The handler block to call when the upload fails due to an error. Receives a single argument NSError `*error`
 
 @see UploadcareFile
  */
- (void)uploadFileFromURL:(NSString *)url
            progressBlock:(UploadcareProgressBlock)progressBlock
             successBlock:(UploadcareSuccessBlock)successBlock
             failureBlock:(UploadcareFailureBlock)failureBlock;

@end
