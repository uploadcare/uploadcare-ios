//
//  UploadcareWidget.m
//  WidgetExample
//
//  Created by Artyom Loenko on 8/3/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UploadcareKit.h>

@class UPCUploadController;
@interface UCAlbumsList : UITableViewController

@property (strong) NSString *serviceName;
@property (readonly) UPCUploadController *widget;

- (id)initWithGrabber:(id)grabber serviceName:(NSString *)serviceName widget:(UPCUploadController *)widget;

@end
