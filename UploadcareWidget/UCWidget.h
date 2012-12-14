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
 * Tells the delegate that the user dismissed the widget */
- (void)uploadcareWidgetDidCancel:(UCWidget *)widget;
/** 
 * Doesn't work yet */
- (void)uploadcareWidget:(UCWidget *)widget didStartUploadingFileNamed:(NSString *)fileName FromURL:(NSURL *)url;
@end

@interface UCWidget : UINavigationController

@property (strong) NSString *navigationTitle;
@property (nonatomic, assign) id<UINavigationControllerDelegate, UCWidgetDelegate> delegate;

- (id)initWithUploadcarePublicKey:(NSString *)publicKey;

- (void)setUploadFailureBlock:(UploadcareFailureBlock)failureBlock;
- (void)setUploadCompletionBlock:(UploadcareSuccessBlock)completionBlock;

- (void)enableFacebook;
- (void)enableFlickrWithAPIKey:(NSString *)flickrAPIKey flickrAPISecret:(NSString *)flickrAPISecret;
- (void)enableInstagramWithClientId:(NSString *)instagramAppId;


@end

