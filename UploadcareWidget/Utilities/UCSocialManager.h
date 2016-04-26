//
//  UCSocialManager.h
//  ExampleProject
//
//  Created by Yury Nechaev on 14.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UCSocialEntry;
@class UCSocialSource;

#define SharedSocialManager [UCSocialManager sharedInstance]

/**
 *  This class was designed to help user in fetching social sources and presenting document controller.
 *  The following methods are invoked from the example controller UCWidgetVC. You can use existing implementation,
 *  or your own, taking care about what sources do you want to show.
 */
@interface UCSocialManager : NSObject

+ (instancetype)  sharedInstance;

/**
 *  Requests social sources from Uploadcare service and returnes them as an array of UCSocialSource objects.
 *
 *  @param completion Completion handler is invoked when the request is finished and deserialized.
 */
- (void)fetchSocialSourcesWithCompletion:(void(^)(NSArray<UCSocialSource*> *response, NSError *error))completion;

/**
 *  Calls UIDocumentMenuViewController controller to present from the provided controller, handles it's delegates
 *  and uploads local file when choosen.
 *
 *  @param viewController  UIViewController reference to present from.
 *  @param progressBlock   Progress handler is invoked during upload progress callbacks, 
 *  showing the amount of the uploaded data.
 *  @param completionBlock Completion handler is invoked when the request is finished and deserialized.
 *
 *  @return UIDocumentMenuViewController controller instance which user can present by the preffered style.
 */
- (UIDocumentMenuViewController *)documentControllerFrom:(UIViewController *)viewController
                                                progress:(void(^)(NSUInteger bytesSent, NSUInteger bytesExpectedToSend))progressBlock
                                              completion:(void(^)(NSString *fileId, NSError *error))completionBlock;

@end
