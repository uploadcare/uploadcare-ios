//
//  UPCUpload_Private.h
//  Uploadcare for iOS
//
//  Created by Zoreslav Khimich on 13/01/2013.
//

#import "UPCUpload.h"

@interface UPCUpload ()
@property (readwrite, strong) NSURL *sourceURL;
@property (readwrite, strong) UIImage *thumbnail;
@property (readwrite, strong) NSURL *thumbnailURL;
@property (readwrite, strong) NSString *title;
/* e.g. facebook, flickr, user-supplied URL etc */
@property (readwrite, strong) NSString *sourceType;
@property (readwrite, strong) NSString *filename;

+ (void)uploadAssetForURL:(NSURL *)assetURL delegate:(id<UPCUploadDelegate>)delegate;
+ (void)uploadRemoteForURL:(NSURL *)remoteURL title:(NSString *)title thumbnailURL:(NSURL *)thumbnailURL thumbnailImage:(UIImage *)thumbnailImage delegate:(id<UPCUploadDelegate>)delegate source:(NSString*)sourceName;
@end
