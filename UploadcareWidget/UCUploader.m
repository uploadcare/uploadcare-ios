//
//  UCUploader.m
//  WidgetExample
//
//  Created by Zoreslav Khimich on 11/7/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <UploadcareKit.h>
#import "UCUploader.h"
//#import "SVProgressHUD.h"

void UCUploadFile(NSString *fileURL, UploadcareSuccessBlock success, UploadcareProgressBlock progress, UploadcareFailureBlock failure) {
    NSString *const kUploadingText = NSLocalizedString(@"Uploading", @"Upload HUD text");
    [[UploadcareKit shared]uploadFileFromURL:fileURL progressBlock:^(long long bytesDone, long long bytesTotal) {
        if (progress) progress(bytesDone, bytesTotal);
     } successBlock:^(NSString *fileId) {
         /* on upload completed */
         if (success) success(fileId);
         else NSLog(@"Upload finished, file_id = '%@'", fileId);
     } failureBlock:^(NSError *error) {
         if (failure) failure(error);
         else NSLog(@"Uploadcare failed to upload a file.\n\n%@", error);
     }];
}