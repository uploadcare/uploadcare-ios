//
//  UploadcareKit.h
//  UploadcareKit
//
//  Created by Artyom Loenko on 8/1/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "UploadcareFile.h"
#import "UploadcareError.h" 


/**
 @typedef Block type used to define blocks called repeatedly during an operation to indicate the operation progress
 
 @param bytesDone   Number of bytes already processed
 @param bytesTotal  Number of total bytes expexted to process during the operation
 */
typedef void(^UploadcareProgressBlock)(long long bytesDone, long long bytesTotal);
/**
 @typedef Blocks of this type are called once per succesfully completed operation
 
 @param uploadedFile    Object that describes the uploaded file
 */
typedef void(^UploadcareSuccessBlock)(UploadcareFile *uploadedFile);
/**
 @typedef Blocks of this type are called when an operation fails due to an error
 
 @param error   NSError object that contains the error code and description
 */
typedef void(^UploadcareFailureBlock)(NSError *error);

/**
 * TODO: Write something meaningful here
 * 
 * This is the main class, mon.
 */
@interface UploadcareKit : NSObject 

/* Thread-safe singleton accessor to UploadcareKit */
+ (id)shared;

/** Uploadcare public key
 */
@property (nonatomic) NSString* publicKey;
@property (nonatomic) NSString* secretKey __attribute__((deprecated("This is not going last long, beware")));

/**
 Uploads an arbitrary file (e.g. an image, a movie clip, a spreadsheet document, etc.) with the content provided by the NSData argument.
 
 @param filename        The name to give the file when the file is uploaded.
 @param data            The data to upload.
 @param contentType     The media type of the file, see http://en.wikipedia.org/wiki/Internet_media_type
 @param progressBlock   The block to call repeatedly during the upload. Receives two arguments: **long long** `bytesDone` and **long long** `bytesTotal`.
 @param successBlock    The handler block to call when the upload is completed succesfully. Receives a single argument UploadcareFile `*uploadedFile`.
 @param failureBlock    The handler block to call when the upload fails due to an error. Receives a single argument NSError `*error`
*/
- (void)uploadFileWithName:(NSString *)filename
                      data:(NSData *)data
               contentType:(NSString *)contentType
             progressBlock:(UploadcareProgressBlock)progressBlock
              successBlock:(UploadcareSuccessBlock)successBlock
              failureBlock:(UploadcareFailureBlock)failureBlock;

/**
 Uploads a file from URL
 
 @param url             The URL used to retrieve the file.
 @param progressBlock   The block to call repeatedly during the upload. Receives two arguments: **long long** `bytesDone` and **long long** `bytesTotal`.
 @param successBlock    The handler block to call when the upload is completed succesfully. Receives a single argument UploadcareFile `*uploadedFile`.
 @param failureBlock    The handler block to call when the upload fails due to an error. Receives a single argument NSError `*error`
 
 @see UploadcareFile
  */
- (void)uploadFileFromURL:(NSString *)url
            progressBlock:(UploadcareProgressBlock)progressBlock
             successBlock:(UploadcareSuccessBlock)successBlock
             failureBlock:(UploadcareFailureBlock)failureBlock;

@end
