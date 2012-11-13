//
//  UploadcareMenu.h
//  WidgetSample
//
//  Created by Zoreslav Khimich on 11/6/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <UploadcareKit.h>

#import "UCMenuViewController.h"

@interface UCUploadViewController : UCMenuViewController<UIAlertViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic) NSString *navigationTitle;

- (id)init;

@property (strong) UploadcareSuccessBlock uploadCompletionBlock;
@property (strong) UploadcareFailureBlock uploadFailureBlock;

@end
