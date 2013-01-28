//
//  UPCUploadController.h
//  WidgetSample
//
//  Created by Zoreslav Khimich on 11/6/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UploadcareKit.h>
#import <UPCUploadDelegate.h>

@class UPCUploadController;

@interface UPCUploadController : UINavigationController

@property (nonatomic, assign) NSObject<UPCUploadDelegate> *uploadDelegate;

- (id)initWithUploadcarePublicKey:(NSString *)publicKey;

@property (nonatomic, weak) UIPopoverController *popover;

- (void)enableFacebook;
- (void)enableFlickrWithAPIKey:(NSString *)flickrAPIKey flickrAPISecret:(NSString *)flickrAPISecret;
- (void)enableInstagramWithClientId:(NSString *)instagramAppId;

@end

