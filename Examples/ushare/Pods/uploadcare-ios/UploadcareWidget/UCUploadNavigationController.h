//
//  UCUploadNavigationController.h
//  WidgetSample
//
//  Created by Zoreslav Khimich on 11/6/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UploadcareKit.h>

@interface UCUploadNavigationController : UINavigationController

@property (strong) NSString *navigationTitle;

- (id)initWithUploadcarePublicKey:(NSString *)publicKey;

- (void)setUploadFailureBlock:(UploadcareFailureBlock)failureBlock;
- (void)setUploadCompletionBlock:(UploadcareSuccessBlock)completionBlock;

- (void)enableFacebook;
- (void)enableFlickrWithAPIKey:(NSString *)flickrAPIKey flickrAPISecret:(NSString *)flickrAPISecret;
- (void)enableInstagramWithClientId:(NSString *)instagramAppId;


@end

