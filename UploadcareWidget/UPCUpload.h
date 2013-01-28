//
//  UPCUpload.h
//  Uploadcare for iOS
//
//  Created by Zoreslav Khimich on 13/01/2013.
//
//

#import <Foundation/Foundation.h>
#import "UPCUploadDelegate.h"

/** UPCUpload represent a single file upload transfer. */
@interface UPCUpload : NSObject

/** URL of the file being uploaded */
@property (readonly, strong) NSURL *sourceURL;

/** Thumbnail image for the file being uploaded (if available) or nil */
@property (readonly, strong) UIImage *thumbnail;

/** Thumbnail image URL (if available) or nil.
 
 No guarantee regarding the image on the other end whatsoever, e.g. it may or may not be available, may has any size etc. */
@property (readonly, strong) NSURL *thumbnailURL;

/** Image title (if available) or nil. */
@property (readonly, strong) NSString *title;

/** Image file name */
@property (readonly, strong) NSString *filename;

/** An arbitrary user info object associated with the upload. */
@property (strong, nonatomic) id userInfo;

@end
