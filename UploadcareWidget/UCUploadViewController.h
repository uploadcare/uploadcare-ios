//
//  UploadcareMenu.h
//  WidgetSample
//
//  Created by Zoreslav Khimich on 11/6/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <UploadcareKit.h>

#import "UCMenuViewController.h"
#import "UCWidget.h"

@interface UCUploadViewController : UCMenuViewController<UIAlertViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic) NSString *navigationTitle;

- (id)initWithWidget:(UCWidget *)widget;

@property (strong) UploadcareSuccessBlock uploadCompletionBlock;
@property (strong) UploadcareFailureBlock uploadFailureBlock;

@end
