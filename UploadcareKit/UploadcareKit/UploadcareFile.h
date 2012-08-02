//
//  UploadCareFile.h
//  UploadCareKit
//
//  Created by Artyom Loenko on 6/1/12.
//  Copyright (c) 2012 artyom.loenko@mac.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Official documentation about REST https://github.com/uploadcare/docs/blob/newdocs/reference/basic/rest/resources.markdown
 
 JSON example:
 {
    "file_id": "27c7846b-a019-4516-a5e4-de635f822161",
    "last_keep_claim": "2012-07-19T17:07:14.989",
    "made_public": true,
    "mime_type": "image/jpeg",
    "on_s3": true,
    "original_file_url": "http://s3.amazonaws.com/uploadcare/27c7846b-a019-4516-a5e4-de635f822161/sample_small.jpg",
    "original_filename": "sample_small.jpg",
    "removed": null,
    "size": 290556,
    "upload_date": "2012-06-11T15:20:17.905",
    "url": "http://api.uploadcare.com/files/27c7846b-a019-4516-a5e4-de635f822161/"
 }
 */

@interface UploadcareFile : NSObject

@property(nonatomic, copy) NSDictionary* info;

/**
 Return API URI for BASE_URL addition
 */
- (NSString *)apiURI;

/**
 Return file_id as unique file identificator
 */
- (NSString *)file_id;

/**
 Return Keep Claim request timestamp
 */
- (NSDate *)last_keep_claim;

/**
 Return public status
 */
- (BOOL)made_public;

/**
 Return mime-type of file
 */
- (NSString *)mime_type;

/**
 Return current status of file (on S3 storage or not)
 */
- (BOOL)on_s3;

/**
 Return original file url for direct access
 */
- (NSURL *)original_file_url;

/**
 Return original filename that was used on uploading
 */
- (NSString *)original_filename;

/**
 Return current removed status (indicated delete preparation)
 */
- (NSString *)removed;

/**
 Return file size in bytes
 */
- (int)size;

/**
 Return upload date as NSDate object
 */
- (NSDate *)upload_date;

/**
 Return URL that points to Uploadcare API JSON resolver
 */
- (NSURL *)url;

@end
