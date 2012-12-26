//
//  UCUploadNavigationController.h
//  WidgetSample
//
//  Created by Zoreslav Khimich on 11/6/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UploadcareKit.h>

@class UCWidget;

@protocol UCWidgetDelegate <NSObject>
@optional
/** 
 * Tells the delegate that the user dismissed the widget.
 *
 * The delegate is expected to dismiss the controller. */
- (void)uploadcareWidgetDidCancel:(UCWidget *)widget;
/** 
 * Tells the delegate that the user picked a file to upload.
 *
 * The delegate is expected to dismiss the controller. */
- (void)uploadcareWidget:(UCWidget *)widget didStartUploadingFileNamed:(NSString *)fileName fromURL:(NSURL *)url withThumbnail:(UIImage *)thumbnail;
@end

@interface UCWidget : UINavigationController

@property (strong) NSString *navigationTitle;
@property (nonatomic, weak) id<UINavigationControllerDelegate, UCWidgetDelegate> delegate;

- (id)initWithUploadcarePublicKey:(NSString *)publicKey;

@property (strong) UploadcareProgressBlock uploadProgressBlock;
@property (strong) UploadcareSuccessBlock uploadCompletionBlock;
@property (strong) UploadcareFailureBlock uploadFailureBlock;

- (void)enableFacebook;
- (void)enableFlickrWithAPIKey:(NSString *)flickrAPIKey flickrAPISecret:(NSString *)flickrAPISecret;
- (void)enableInstagramWithClientId:(NSString *)instagramAppId;



@end

