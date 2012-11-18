//
//  UCUploader.m
//  WidgetExample
//
//  Created by Zoreslav Khimich on 11/7/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <UploadcareKit.h>
#import "UCUploader.h"
#import "UCHUD.h"

void UCUploadFile(NSString *fileURL, UploadcareSuccessBlock success, UploadcareFailureBlock failure) {
    [UCHUD setText:NSLocalizedString(@"Uploading", @"Upload HUD text")];
    [UCHUD show];
    [UCHUD setProgress:0];
    NSLog(@"Uploading from URL %@...", fileURL);
    [[UploadcareKit shared]uploadFileFromURL:fileURL progressBlock:^(long long bytesDone, long long bytesTotal) {
         [UCHUD setProgress:(float)bytesDone / bytesTotal];
     } successBlock:^(NSString *fileId) {
         /* on upload completed */
         [UCHUD dismiss];
         if (success) success(fileId);
         else NSLog(@"Upload finished, file_id = '%@'", fileId);
     } failureBlock:^(NSError *error) {
         /* on upload failed */
         [UCHUD dismiss];
         if (failure) failure(error);
         else NSLog(@"Uploadcare failed to upload a file.\n\n%@", error);
     }];
}