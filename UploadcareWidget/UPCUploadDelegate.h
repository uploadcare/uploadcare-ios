//
//  UPCWidgetDelegate.h
//  Uploadcare for iOS
//
//  Created by Zoreslav Khimich on 13/01/2013.
//  Copyright (c) 2013 Uploadcare. All rights reserved.

#import <Foundation/Foundation.h>

@class UPCUpload;
@class UPCUploadController;

@protocol UPCUploadDelegate <NSObject>

@optional

/** 
 * Tells the delegate that the user cancelled the pick operation. */
- (void)uploadControllerDidCancel:(UPCUploadController*)controller;

/**
 * Sent to the delegate when the upload starts. */
- (void)uploadDidStart:(UPCUpload *)upload;

/**
 * Sent to the delegate when the upload is aborted. 
 */
- (void)uploadDidCancel:(UPCUpload *)upload;

/**
 * Sent to the delegate to deliver the upload progress. 
 *
 * @param totalBytesTransfered  The total number of bytes transfered during the upload.
 * @param expectedTotalBytes    The number of bytes to be transfered during the upload.
 * @note CGFloat progressPercentage = (CGFloat)totalBytesTransfered / expectedTotalBytes * 100.f;
 */
- (void)upload:(UPCUpload *)upload didTransferTotalBytes:(long long)totalBytesTransfered expectedTotalBytes:(long long)expectedTotalBytes;

/**
 * Sent to the delegate once the upload completes.
 *
 * @param fileId    Uploadcare file_id for the uploaded file. */
- (void)uploadDidFinish:(UPCUpload *)upload destinationFileId:(NSString *)fileId;

/**
 * Sent to the delegate once the upload fails.
 * 
 * @param error     The error causing the failure. */
- (void)upload:(UPCUpload *)upload didFailWithError:(NSError *)error;

@end
