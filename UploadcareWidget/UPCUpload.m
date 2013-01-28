//
//  UPCUpload.m
//  Uploadcare for iOS
//
//  Created by Zoreslav Khimich on 13/01/2013.
//
//

#import "UPCUpload.h"
#import "UPCUpload_Private.h"
#import "UploadcareKit.h"
#import "UCRecentUploads.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation UPCUpload

+ (void)uploadAssetForURL:(NSURL *)assetURL delegate:(id<UPCUploadDelegate>)delegate {
    __block UPCUpload *upload = [[UPCUpload alloc]init];
    upload.sourceURL = assetURL;
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc]init];
    [assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
        /* asset thumbnail */
        upload.thumbnail = [UIImage imageWithCGImage:asset.thumbnail];
        
        /* obtain NSData for the default representation */
        ALAssetRepresentation *repr = [asset defaultRepresentation];
        size_t bufferLength = repr.size;
        uint8_t *buffer = (uint8_t *)malloc(bufferLength);
        NSError *retrievalError;
        NSUInteger bytesWritten = [repr getBytes:buffer fromOffset:0 length:bufferLength error:&retrievalError];
        if (!bytesWritten) {
            free(buffer);
            NSLog(@"ALAsset default representation read error: %@", retrievalError);
            if ([delegate respondsToSelector:@selector(upload:didFailWithError:)]) [delegate upload:upload didFailWithError:retrievalError];
            return;
        }
        NSData *data = [NSData dataWithBytes:buffer length:bufferLength];
        free(buffer);
        
        /* filename */
        upload.filename = repr.filename;
        
        /* initiate upload */
        [[UploadcareKit shared]uploadFileNamed:upload.filename contentData:data contentType:nil progressBlock:^(long long bytesDone, long long bytesTotal) {
            if ([delegate respondsToSelector:@selector(upload:didTransferTotalBytes:expectedTotalBytes:)]) [delegate upload:upload didTransferTotalBytes:bytesDone expectedTotalBytes:bytesTotal];
        } successBlock:^(NSString *fileId) {
            [UCRecentUploads recordUploadWithInfo:@{UCRecentUploadsURLKey:assetURL.absoluteString, UCRecentUploadsSourceTypeKey:@"Library"}];
            if ([delegate respondsToSelector:@selector(uploadDidFinish:destinationFileId:)]) [delegate uploadDidFinish:upload destinationFileId:fileId];
        } failureBlock:^(NSError *error) {
            /* FIXME (what kind of error? is it a good idea to retry?) */
            [UCRecentUploads recordUploadWithInfo:@{UCRecentUploadsURLKey:assetURL.absoluteString, UCRecentUploadsSourceTypeKey:@"Library", UCRecentUploadsErrorKey:error}];
            if ([delegate respondsToSelector:@selector(upload:didFailWithError:)]) [delegate upload:upload didFailWithError:error];
        }];
        /* notify the delegate */
        if ([delegate respondsToSelector:@selector(uploadDidStart:)]) [delegate uploadDidStart:upload];
    } failureBlock:^(NSError *error) {
        NSLog(@"Asset library access error: %@", error);
        if ([delegate respondsToSelector:@selector(upload:didFailWithError:)]) [delegate upload:upload didFailWithError:error];
    }];
}

+ (void)uploadRemoteForURL:(NSURL *)remoteURL title:(NSString *)title thumbnailURL:(NSURL *)thumbnailURL thumbnailImage:(UIImage *)thumbnailImage delegate:(id<UPCUploadDelegate>)delegate source:(NSString*)sourceName {
    __block UPCUpload *upload = [[UPCUpload alloc]init];
    upload.sourceURL = remoteURL;
    upload.title = title;
    upload.thumbnailURL = thumbnailURL;
    upload.thumbnail = thumbnailImage;
    upload.sourceType = sourceName;
    upload.filename = [remoteURL lastPathComponent];
    /* initiate the transfer */
    [[UploadcareKit shared]uploadFileFromURL:remoteURL.absoluteString progressBlock:^(long long bytesDone, long long bytesTotal) {
        if ([delegate respondsToSelector:@selector(upload:didTransferTotalBytes:expectedTotalBytes:)]) [delegate upload:upload didTransferTotalBytes:bytesDone expectedTotalBytes:bytesTotal];
    } successBlock:^(NSString *fileId) {
        /* remember the upload */
        [UCRecentUploads recordUploadWithInfo:@{UCRecentUploadsURLKey:remoteURL.absoluteString, UCRecentUploadsThumbnailURLKey:thumbnailURL ? thumbnailURL.absoluteString : @"", UCRecentUploadsTitleKey:title?title:@"", UCRecentUploadsSourceTypeKey:sourceName}];
        /* notify the delegate */
        if ([delegate respondsToSelector:@selector(uploadDidFinish:destinationFileId:)]) [delegate uploadDidFinish:upload destinationFileId:fileId];
    } failureBlock:^(NSError *error) {
        /* remember the failure */
        [UCRecentUploads recordUploadWithInfo:@{UCRecentUploadsURLKey:remoteURL.absoluteString, UCRecentUploadsThumbnailURLKey:thumbnailURL ? thumbnailURL.absoluteString : @"", UCRecentUploadsTitleKey:title?title:@"", UCRecentUploadsSourceTypeKey:sourceName}];
        /* notify the delegate */
        if ([delegate respondsToSelector:@selector(upload:didFailWithError:)]) [delegate upload:upload didFailWithError:error];
    }];
    /* notify the delegate */
    if ([delegate respondsToSelector:@selector(uploadDidStart:)]) [delegate uploadDidStart:upload];
}

@end
