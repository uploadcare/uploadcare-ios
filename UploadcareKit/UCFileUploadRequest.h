//
//  UCFileUploadRequest.h
//  Riders
//
//  Created by Yury Nechaev on 31.03.16.
//  Copyright © 2016 Whitescape. All rights reserved.
//

#import "UCAPIRequest.h"

@interface UCFileUploadRequest : UCAPIRequest

+ (instancetype)requestWithFileData:(NSData *)fileData
                           fileName:(NSString *)fileName
                           mimeType:(NSString *)mimeType;

+ (instancetype)requestWithFileURL:(NSURL *)fileURL;

@end
