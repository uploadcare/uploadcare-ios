//
//  UploadcareWidget.m
//  WidgetExample
//
//  Created by Artyom Loenko on 8/3/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UploadcareKit.h>

@class UCWidget;
@interface UCAlbumsList : UITableViewController

@property (strong) NSString *serviceName;
@property (readonly) UCWidget *widget;

- (id)initWithGrabber:(id)grabber serviceName:(NSString *)serviceName widget:(UCWidget *)widget;

@end
