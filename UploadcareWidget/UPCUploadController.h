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


/** Maximum image size to upload. Larger images will be downscaled before uploading. 
 
    @note CGSizeMake(0, 0) means unlimited.
 */
@property (nonatomic, assign) CGSize maximumImageSize;

/** Compression quality to use when downscaling an image.
 
    @note Defaults to 0.85
    @see maximumImageSize 
 */
@property (nonatomic, assign) double lossyCompressionQuality;

@end

