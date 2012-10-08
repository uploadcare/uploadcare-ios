//
//  UploadcareKit.h
//  UploadcareKit
//
//  Created by Artyom Loenko on 8/1/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "UploadCareFile.h"

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

@interface UploadcareKit : NSObject {
/**
 Set your public key and secret for requests and validation
 
 @param public Your public key
 @param secret Your secret key
 */
    NSString *_publicKey;
    NSString *_secretKey;
}

/* Thread-safe singleton accessor to UploadcareKit */
+ (id)shared;

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

- (void)setPublicKey:(NSString *)public andSecret:(NSString *)secret;

/**
 Upload your data from specified NSData [images, video, etc.].
 
 Sets the properties with a blocks that executes either the specified success, failure or upload progress block, depending on the state of the request on completion. If error returns a value, which can be caused by an unacceptable status code or content type, then failure is executed. Otherwise, success is executed.
 
 @param filename Sets the filename for uploaded data that can be used on object description
 @param data NSData object with content of your data that you trying to upload
 @param uploadProgressBlock Sets a callback to be called when an undetermined number of bytes have been uploaded to the server. A block object to be called when an undetermined number of bytes have been uploaded to the server. This block has no return value and takes three arguments: the number of bytes written since the last time the upload progress block was called, the total bytes written, and the total bytes expected to be written during the request, as initially determined by the length of the HTTP body. This block may be called multiple times.
 @param success The block to be executed on the completion of a successful request. This block has no return value and takes three arguments: the request sent from the client, the response received from the server, and the UploadcareFile object created from the response data of request.
 @param failure A block object to be executed when the operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data as JSON. This block has no return value and takes three arguments: the request sent from the client, the response received from the server, and the error describing the network or parsing error that occurred.
 */
- (void)uploadFileWithName:(NSString *)filename
                   andData:(NSData *)data
       uploadProgressBlock:(void (^)(NSInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))upload
                   success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UploadcareFile *file))success
                   failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;

/**
 Upload your data from specified URL.
 
 Sets the properties with a blocks that executes either the specified success or failure progress block, depending on the state of the request on completion. If error returns a value, which can be caused by an unacceptable status code or content type, then failure is executed. Otherwise, success is executed.
 
 @param url The object to be loaded asynchronously during execution of the operation
 @param progressBlock The block to be executed repeatedly during the upload. Takes two arguments: the amount of data already uploaded, and the total amount to be uploaded during the operation.
 @param success A block object to be executed when the operation finishes successfully. The block takes one argument: resulting UploadcareFile object.
 @param failure A block object to be executed when the operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data as JSON. This block has no return value and takes one argument: the error describing the network or parsing error that occurred.
 */
- (void)uploadFileWithURL:(NSString *)url
            progressBlock:(void (^)(long long uploadedBytes, long long totalBytes))progressBlock
             successBlock:(void (^)(UploadcareFile *file))successBlock
             failureBlock:(void (^)(NSError *error))failureBlock;

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
