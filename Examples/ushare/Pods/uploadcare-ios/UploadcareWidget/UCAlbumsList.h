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

@property (strong) UploadcareSuccessBlock uploadCompletionBlock;
@property (strong) UploadcareFailureBlock uploadFailureBlock;
@property (strong) NSString *serviceName;

- (id)initWithGrabber:(id)grabber serviceName:(NSString *)serviceName;

@end
