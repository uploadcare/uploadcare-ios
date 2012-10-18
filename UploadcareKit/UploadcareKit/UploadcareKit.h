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

#define UPLOADCARE_NEW_IMAGE_NOTIFICATION @"Uploadcare should upload new image"

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
 TODO: Write something meaningful here 
 */
@interface UploadcareKit : NSObject {
    NSString *_publicKey;
    NSString *_secretKey;
}

/* Thread-safe singleton accessor to UploadcareKit */
+ (id)shared;

#pragma mark - Move this elsewhere:

/**
 Download image for any service at background with placeholder value
 
 @param url NSURL for image
 @param placeholder UIImage instance for placeholder
 */
+ (void)downloadImageAtURL:(NSURL *)url withPlaceholder:(UIImage *)placeholder forImageView:(UIImageView *) imageView;

/**
 The MD5 Message-Digest Algorithm cryptographic hash function that produces a 128-bit (16-byte) hash value. Specified in RFC 1321. Used for client-server auth procedure.
 
 @param input NSString instance for which you want to get md5
 @return MD5 as NSString instance
 */
+ (NSString *)md5ForString:(NSString *)input;

/**
 SHA-1 is a cryptographic hash function stands for "secure hash algorithm". Used for client-server auth procedure.
 
 @param input NSString instance for which you want to get SHA1 hash
 @param key Your secret key for hash generation
 @return SHA1 as NSString instance
 */
+ (NSString *)hashedValueForString:(NSString *)input WithKey:(NSString *) key;
+ (NSString *)validateUUID:(NSString *)uuid;

#pragma mark - This belongs here:

/**
 Set your public key and secret for requests and validation
 
 @param public Your public key
 @param secret Your secret key
 */
- (void)setPublicKey:(NSString *)public secretKey:(NSString *)secret;

/**
 Uploads a file of any kind (e.g. an image, a movie clip, a spreadsheet document, etc.) which content is provided by an NSData object.
 
 @param filename        The name to give the file when the file is uploaded.
 @param data            The data to upload.
 @param progressBlock   The block to call repeatedly during the upload. Receives two arguments: **long long** `bytesDone` and **long long** `bytesTotal`.
 @param successBlock    The handler block to call when the upload is completed succesfully. Receives a single argument UploadcareFile `*uploadedFile`.
 @param failureBlock    The handler block to call when the upload fails due to an error. Receives a single argument NSError `*error`
*/
- (void)uploadFileWithName:(NSString *)filename
                      data:(NSData *)data
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

/**
 Get file info of early uploaded file. example: 
 { "file_id": "27c7846b-a019-4516-a5e4-de635f822161", "last_keep_claim": "2012-07-19T17:07:14.989", "made_public": true, "mime_type": "image/jpeg", "on_s3": true, "original_file_url": "http://s3.amazonaws.com/uploadcare/27c7846b-a019-4516-a5e4-de635f822161/sample_small.jpg", "original_filename": "sample_small.jpg", "removed": null, "size": 290556, "upload_date": "2012-06-11T15:20:17.905", "url": "http://api.uploadcare.com/files/27c7846b-a019-4516-a5e4-de635f822161/" }
 
 Sets the properties with a blocks that executes either the specified success or failure progress block, depending on the state of the request on completion. If error returns a value, which can be caused by an unacceptable status code or content type, then failure is executed. Otherwise, success is executed.
 
 @param file_id Unique identificator of uploaded file from UploadcareFile or another storage
 @param success A block object to be executed when the operation finishes successfully. This block has no return value and takes three arguments: the response received from the server, file info as NSDictionaty and the UploadcareFile object created from the response data of request.
 @param failure A block object to be executed when the operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data as JSON. This block has no return value and takes two arguments: the response received from the server, and the error describing the network or parsing error that occurred.
 */
- (void)requestFile:(NSString *)file_id
        withSuccess:(void (^)(NSHTTPURLResponse *response, id JSON, UploadcareFile *file))success
         andFailure:(void (^)(id responseObject, NSError *error))failure;

/**
 Get file list of early uploaded files for your account.
 
 Sets the properties with a blocks that executes either the specified success or failure progress block, depending on the state of the request on completion. If error returns a value, which can be caused by an unacceptable status code or content type, then failure is executed. Otherwise, success is executed.
 
 @param success A block object to be executed when the operation finishes successfully. This block has no return value and takes three arguments: the response received from the server, files info as NSDictionaty and the array of UploadcareFile objects created from the response data of request.
 @param andFailure A block object to be executed when the operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data as JSON. This block has no return value and takes two arguments: the response received from the server, and the error describing the network or parsing error that occurred.
 */
- (void)requestFileListWithSuccess:(void (^)(NSHTTPURLResponse *response, id JSON, NSArray *files))success
                        andFailure:(void (^)(id responseObject, NSError *error))failure;

/**
 Keep early uploaded file at your storage.
 
 Sets the properties with a status to keep and UploadcareFile object.
 
 @param status Keep or unkeep file with BOOL value YES or NO
 @param file UploadcareFile instance that keep some data as file_id for request
 */
- (void) keep:(BOOL)status
      forFile:(UploadcareFile *)file;

/**
 Keep early uploaded file at your storage.
 
 Sets the properties with a blocks that executes either the specified success or failure progress block, depending on the state of the request on completion. If error returns a value, which can be caused by an unacceptable status code or content type, then failure is executed. Otherwise, success is executed.
 
 @param status Keep or unkeep file with BOOL value YES or NO
 @param file UploadcareFile instance that keep some data as file_id for request
 @param success A block object to be executed when the operation finishes successfully. This block has no return value and takes three arguments: the response received from the server, JSON with server response and tUploadcareFile object instanced or filled from the response data of request.
 @param andFailure A block object to be executed when the operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data as JSON. This block has no return value and takes two arguments: the response received from the server, and the error describing the network or parsing error that occurred.
 */
- (void)keep:(BOOL)status
     forFile:(UploadcareFile *)file
     success:(void (^)(NSHTTPURLResponse *response, id JSON, UploadcareFile *file))success
  andFailure:(void (^)(NSHTTPURLResponse *response, NSError *error))failure;

/**
 Delete uploaded file from your storage.
 Note: Marks a file as a deleted. It's no longer available from s3, and is scheduled to be deleted in a couple of hours
 
 Sets the properties with a blocks that executes either the specified success or failure progress block, depending on the state of the request on completion. If error returns a value, which can be caused by an unacceptable status code or content type, then failure is executed. Otherwise, success is executed.
 
 @param file UploadcareFile instance that keep some data as file_id for request
 @param success A block object to be executed when the operation finishes successfully. This block has no return value and takes two arguments: the response received from the server and JSON with server response.
 @param andFailure A block object to be executed when the operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data as JSON. This block has no return value and takes two arguments: the response received from the server, and the error describing the network or parsing error that occurred.
 */
- (void)deleteFile:(UploadcareFile *)file
           success:(void (^)(NSHTTPURLResponse *response))success
        andFailure:(void (^)(NSHTTPURLResponse *response, NSError *error))failure;

@end
