//
//  UploadcareStatusWatcher.h
//  UploadcareKit
//
//  Created by Zoreslav Khimich on 10/8/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTPusherDelegate.h"

@class UploadCareFile;

typedef void (^UCSWUploadProgressBlock)(long long uploaded, long long total);
typedef void (^UCSWUploadSuccessBlock)(UploadcareFile *file);
typedef void (^UCSWUploadFailureBlock)(NSError *error);

@interface UploadcareStatusWatcher : NSObject<PTPusherDelegate>

+ (id)watchUploadWithToken:(NSString *)token progressBlock:(UCSWUploadProgressBlock)progressBlock successBlock:(UCSWUploadSuccessBlock)successBlock failureBlock:(UCSWUploadFailureBlock)failureBlock;

+ (void)preheatPusher;

@end
