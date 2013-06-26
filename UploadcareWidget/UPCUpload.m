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
#import <ImageIO/ImageIO.h>

@implementation UPCUpload

+ (NSData *)dataFromAssetRepresentation:(ALAssetRepresentation *)repr maximumSize:(CGSize)maximumSize lossyCompressionQuality:(double)lossyCompressionQuality error:(NSError **)error {
    
    if ((repr.dimensions.width <= maximumSize.width && repr.dimensions.height)
        ||(maximumSize.width == 0 && maximumSize.height == 0)) {
        
        /* Resize is not neccessary, return the representation's data as is */
        
        size_t bufferLength = repr.size;
        uint8_t *buffer = (uint8_t *)malloc(bufferLength);
        
        NSUInteger bytesWritten = [repr getBytes:buffer fromOffset:0 length:bufferLength error:error];
        
        NSData *resultingData = nil;
        
        if (bytesWritten)
            resultingData = [NSData dataWithBytes:buffer length:bufferLength];
        
        free(buffer);
        
        return resultingData;
        
    } else {
        
        CGImageRef imageRef = repr.fullResolutionImage;
        
        CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
        
        double scaleRatio = MIN(maximumSize.width / imageSize.width, maximumSize.height / imageSize.height);
        
        CGSize targetSize = CGSizeMake(imageSize.width * scaleRatio, imageSize.height * scaleRatio);
        
        size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
        size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);

        CGColorSpaceRef colorspace = CGImageGetColorSpace(imageRef);
        
        CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
        
        CGContextRef ctx = CGBitmapContextCreate(NULL, ceilf(targetSize.width), ceilf(targetSize.height), bitsPerComponent, bytesPerRow, colorspace, bitmapInfo);
        
        CGContextDrawImage(ctx, CGRectMake(0, 0, targetSize.width, targetSize.height), imageRef);
        
        CGImageRef resultingImageRef = CGBitmapContextCreateImage(ctx);
        
        CGContextRelease(ctx);
        
        NSMutableData *resultingData = [[NSMutableData alloc] init];
        
        CGImageDestinationRef idst = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)resultingData, (__bridge CFStringRef)repr.UTI, 1, NULL);
        
        NSMutableDictionary *metadata = [repr.metadata mutableCopy];
        
        if ([repr.UTI isEqualToString:(NSString *)kUTTypeJPEG])
            metadata[(NSString *)kCGImageDestinationLossyCompressionQuality] = @(lossyCompressionQuality);

        CGImageDestinationAddImage(idst, resultingImageRef, (__bridge CFDictionaryRef)metadata);
        
        CGImageDestinationFinalize(idst);
        
        CFRelease(idst);
        
        return resultingData;
        
    }
    
    
}

+ (void)uploadAssetWithURL:(NSURL *)assetURL delegate:(id<UPCUploadDelegate>)delegate maximumSize:(CGSize)maximumSize lossyCompressionQuality:(double)lossyCompressionQuality {
    __block UPCUpload *upload = [[UPCUpload alloc]init];
    upload.sourceURL = assetURL;
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc]init];
    [assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
        
        /* asset thumbnail */
        upload.thumbnail = [UIImage imageWithCGImage:asset.thumbnail];
        
        /* obtain NSData for the default representation */
        
        ALAssetRepresentation *repr = [asset defaultRepresentation];
        
        NSError *retrievalError = nil;
        
        NSData *data = [self dataFromAssetRepresentation:repr maximumSize:maximumSize lossyCompressionQuality:lossyCompressionQuality error:&retrievalError];
        
        if (!data) {
        
            NSLog(@"ALAsset default representation read error: %@", retrievalError);
            
            if ([delegate respondsToSelector:@selector(upload:didFailWithError:)]) [delegate upload:upload didFailWithError:retrievalError];
            
            return;
            
        }

        upload.filename = repr.filename;
        
        /* start uploading */        
        
        upload.uploadOperation = [[UploadcareKit shared] startUploadingData:data withName:upload.filename contentType:nil store:NO progressBlock:^(long long bytesDone, long long bytesTotal) {
            
            if ([delegate respondsToSelector:@selector(upload:didTransferTotalBytes:expectedTotalBytes:)]) [delegate upload:upload didTransferTotalBytes:bytesDone expectedTotalBytes:bytesTotal];
            
        } successBlock:^(NSString *fileId) {
            
            [UCRecentUploads recordUploadWithInfo:@{UCRecentUploadsURLKey:assetURL.absoluteString, UCRecentUploadsSourceTypeKey:@"Library"}];
            
            if ([delegate respondsToSelector:@selector(uploadDidFinish:destinationFileId:)]) [delegate uploadDidFinish:upload destinationFileId:fileId];

        } failureBlock:^(NSError *error) {
            
            [UCRecentUploads recordUploadWithInfo:@{UCRecentUploadsURLKey:assetURL.absoluteString, UCRecentUploadsSourceTypeKey:@"Library", UCRecentUploadsErrorKey:error}];
            
            if ([delegate respondsToSelector:@selector(upload:didFailWithError:)]) [delegate upload:upload didFailWithError:error];
            
        }];
        

        /* notify the delegate */
        if ([delegate respondsToSelector:@selector(uploadDidStart:)])
            [delegate uploadDidStart:upload];
        
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
    
    /* start uploading */
    
    upload.uploadOperation = [[UploadcareKit shared] startUploadingFromURL:remoteURL store:NO progressBlock:^(long long bytesDone, long long bytesTotal) {
        
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

- (void)cancel {
    
    [self.uploadOperation cancel];
    
}

@end
