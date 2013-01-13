//
//  UploadcareMenu.h
//  WidgetSample
//
//  Created by Zoreslav Khimich on 11/6/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <UploadcareKit.h>

#import "UCMenuViewController.h"
#import "UPCUploadController.h"

@interface UCUploadViewController : UCMenuViewController<UIAlertViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

- (id)initWithWidget:(UPCUploadController *)widget;

@property (nonatomic, strong) UIImagePickerController *imagePicker;

@end
