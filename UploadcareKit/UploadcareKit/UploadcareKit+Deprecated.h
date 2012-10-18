//
//  UploadcareKit+Deprecated.h
//  UploadcareKit
//
//  Created by Zoreslav Khimich on 10/18/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UploadcareKit.h"

@interface UploadcareKit (Deprecated)

@property (nonatomic) NSString* secretKey;

/**
 Download image for any service at background with placeholder value
 
 @param url NSURL for image
 @param placeholder UIImage instance for placeholder
 */
+ (void)downloadImageAtURL:(NSURL *)url withPlaceholder:(UIImage *)placeholder forImageView:(UIImageView *) imageView;


/**
 Set your public key and secret for requests and validation
 
 @param public Your public key
 @param secret Your secret key
 */
- (void)setPublicKey:(NSString *)public secretKey:(NSString *)secret;


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
