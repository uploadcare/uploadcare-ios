//
//  UCRemoteFileUploadRequest.m
//  Cloudkit test
//
//  Created by Yury Nechaev on 01.04.16.
//  Copyright © 2016 Riders. All rights reserved.
//

#import "UCRemoteFileUploadRequest.h"
#import "UCConstantsHeader.h"

@implementation UCRemoteFileUploadRequest

+ (instancetype)requestWithRemoteFileURL:(NSURL *)fileURL {
    return [[UCRemoteFileUploadRequest alloc] initWithRemoteFileURL:fileURL];
}

- (id)initWithRemoteFileURL:(NSURL *)fileURL {
    NSParameterAssert(fileURL);
    self = [super init];
    if (self) {
        self.path = UCRemoteFileUploadingPath;
        self.parameters = @{@"source_url": fileURL.absoluteString};
    }
    return self;
}

@end
