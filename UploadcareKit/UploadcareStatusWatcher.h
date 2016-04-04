//
//  UploadcareStatusWatcher.h
//  UploadcareKit
//
//  Created by Zoreslav Khimich on 10/8/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadcareStatusWatcher : NSObject

+ (id)watchUploadWithToken:(NSString *)token progressBlock:(UploadcareProgressBlock)progressBlock successBlock:(UploadcareSuccessBlock)successBlock failureBlock:(UploadcareFailureBlock)failureBlock;

+ (void)preheatPusher;

@end
