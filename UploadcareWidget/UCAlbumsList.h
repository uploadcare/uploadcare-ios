//
//  UploadcareWidget.m
//  WidgetExample
//
//  Created by Artyom Loenko on 8/3/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UploadcareKit.h>

@interface UCAlbumsList : UITableViewController

@property (weak) UploadcareSuccessBlock uploadCompletionBlock;
@property (weak) UploadcareFailureBlock uploadFailureBlock;

- (id)initWithGrabber:(id)grabber serviceName:(NSString *)serviceName;

@end
