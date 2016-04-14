//
//  UCSocialManager.h
//  ExampleProject
//
//  Created by Yury Nechaev on 14.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UCSocialEntry;
@class UCSocialSource;

@interface UCSocialManager : NSObject

+ (void)fetchSocialSourcesWithCompletion:(void(^)(NSArray<UCSocialSource*> *response, NSError *error))completion;
+ (void)uploadSocialEntry:(UCSocialEntry *)entry
                forSource:(UCSocialSource *)source
                 progress:(void(^)(NSUInteger bytesSent, NSUInteger bytesExpectedToSend))progressBlock
               completion:(void(^)(BOOL completed, NSString *fileId, NSError *error))completionBlock;

@end
