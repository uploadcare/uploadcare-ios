//
//  UCFileUploadRequest.m
//  Riders
//
//  Created by Yury Nechaev on 31.03.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCFileUploadRequest.h"
#import "UCConstantsHeader.h"
#import <MobileCoreServices/UTType.h>


@interface UCFileUploadRequest ()
@end

@implementation UCFileUploadRequest

- (NSMutableURLRequest *)request {
    NSURLComponents *components = [NSURLComponents new];
    [components setScheme:UCAPIProtocol];
    [components setHost:UCApiRoot];
    [components setPath:self.path];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[components URL]];
    [request setHTTPMethod:@"POST"];
    return request;
}

+ (instancetype)requestWithFileData:(NSData *)fileData
                           fileName:(NSString *)fileName
                           mimeType:(NSString *)mimeType {
    return [[UCFileUploadRequest alloc] initWithFileData:fileData fileName:fileName mimeType:mimeType];
}

+ (instancetype)requestWithFileURL:(NSURL *)fileURL {
    return [[UCFileUploadRequest alloc] initWithFileURL:fileURL];
}

- (id)initWithFileData:(NSData *)fileData
              fileName:(NSString *)fileName
              mimeType:(NSString *)mimeType {
    NSParameterAssert(fileData);
    NSParameterAssert(fileName);
    NSParameterAssert(mimeType);
    self = [self init];
    if (self) {
        self.payload = [UCAPIRequestPayload payloadWithData:fileData
                                                       name:@"file"
                                                   fileName:fileName
                                                   mimeType:mimeType];
    }
    return self;
}

- (id)initWithFileURL:(NSURL *)fileURL {
    NSParameterAssert(fileURL);
    self = [self init];
    if (self) {
        NSAssert([fileURL isFileURL], @"fileURL should be file URL");
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:[fileURL path]];
        if (data) {
            NSString *fileName = [fileURL lastPathComponent];
            NSString *mimeType = UCContentTypeForPathExtension([fileURL pathExtension]);
            self.payload = [UCAPIRequestPayload payloadWithData:data
                                                           name:@"file"
                                                       fileName:fileName
                                                       mimeType:mimeType];
        }
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        self.path = UCFileUploadingPath;
    }
    return self;
}

static inline NSString * UCContentTypeForPathExtension(NSString *extension) {
#ifdef __UTTYPE__
    NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
    NSString *contentType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
    if (!contentType) {
        return @"application/octet-stream";
    } else {
        return contentType;
    }
#else
    return @"application/octet-stream";
#endif
}

@end
