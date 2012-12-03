//
//  UCUploader.m
//  WidgetExample
//
//  Created by Zoreslav Khimich on 11/7/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <UploadcareKit.h>
#import "UCUploader.h"
#import "SVProgressHUD.h"

void UCUploadFile(NSString *fileURL, UploadcareSuccessBlock success, UploadcareFailureBlock failure) {
    NSString *const kUploadingText = NSLocalizedString(@"Uploading", @"Upload HUD text");
    [SVProgressHUD showProgress:0 status:kUploadingText maskType:SVProgressHUDMaskTypeNone];
    [[UploadcareKit shared]uploadFileFromURL:fileURL progressBlock:^(long long bytesDone, long long bytesTotal) {
        [SVProgressHUD showProgress:(float)bytesDone / bytesTotal status:kUploadingText maskType:SVProgressHUDMaskTypeNone];
     } successBlock:^(NSString *fileId) {
         /* on upload completed */
         [SVProgressHUD dismiss];
         [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Done", @"Uploading done HUD text")];
         if (success) success(fileId);
         else NSLog(@"Upload finished, file_id = '%@'", fileId);
     } failureBlock:^(NSError *error) {
         /* on upload failed */
         [SVProgressHUD dismiss];
         [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Error", @"Uploading failed HUD text")];
         if (failure) failure(error);
         else NSLog(@"Uploadcare failed to upload a file.\n\n%@", error);
     }];
}