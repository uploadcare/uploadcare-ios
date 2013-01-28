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
 * Sent to the delegate when the upload is aborted. */
- (void)uploadDidCancel:(UPCUpload *)upload;

/**
 * Sent to the delegate to deliver progress information for the upload. */
- (void)upload:(UPCUpload *)upload didTransferTotalBytes:(long long)totalBytesTransfered expectedTotalBytes:(long long)expectedTotalBytes;

/**
 * Sent to the delegate when the upload successfully finish.
 *
 * @param fileId    Uploadcare file_id for the freshly uploaded file. */
- (void)uploadDidFinish:(UPCUpload *)upload destinationFileId:(NSString *)fileId;

/**
 * Sent to the delegate when the upload fails due to an error.
 * 
 * @param error     The error causing the failure. */
- (void)upload:(UPCUpload *)upload didFailWithError:(NSError *)error;

@end
