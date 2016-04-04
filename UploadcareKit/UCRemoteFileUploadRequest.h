//
//  UCRemoteFileUploadRequest.h
//  Cloudkit test
//
//  Created by Yury Nechaev on 01.04.16.
//  Copyright © 2016 Riders. All rights reserved.
//

#import "UCAPIRequest.h"

@interface UCRemoteFileUploadRequest : UCAPIRequest

+ (instancetype)requestWithRemoteFileURL:(NSURL *)fileURL;

@end
