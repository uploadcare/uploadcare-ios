//
//  UCUploader.h
//  WidgetExample
//
//  Created by Zoreslav Khimich on 11/7/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UploadcareKit.h"

void UCUploadFile(NSString *fileURL, UploadcareSuccessBlock success, UploadcareProgressBlock progress, UploadcareFailureBlock failure);
