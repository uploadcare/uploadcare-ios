//
//  UploadcareKit.m
//  UploadcareKit
//
//  Created by Artyom Loenko on 8/1/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UploadcareKit.h"
#import "UploadcareStatusWatcher.h"

#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"
#import "MobileCoreServices/UTType.h"

NSString * const UploadcareBaseUploadURL = @"https://upload.staging0.uploadcare.com";

@interface UploadcareKit () {
    NSString *_secretKey;
}

+ (AFHTTPClient *)sharedUploadClient;
@end

    
@implementation UploadcareKit

+ (AFHTTPClient *)sharedUploadClient {
    static AFHTTPClient *_sharedUploadClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedUploadClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:UploadcareBaseUploadURL]];
    });
    return _sharedUploadClient;
}

- (NSString *)publicKey {
    if (!_publicKey) {
        [NSException raise:UploadcareMissingPublicKeyException format:@"The publicKey property must be set. You can get your public key from https://uploadcare.com/accounts/settings/"];
    }
    
    return _publicKey;
}

+ (id)shared
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}
         
#pragma mark - Kit Actions

- (id)init {
    if (self = [super init]) {
        [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObjects:@"application/vnd.uploadcare-v0.2+json", nil]];
        [UploadcareStatusWatcher preheatPusher];
    }
    return self;
}

- (void)uploadFileWithName:(NSString *)filename
                      data:(NSData *)data
               contentType:(NSString *)contentType
             progressBlock:(UploadcareProgressBlock)progressBlock
              successBlock:(UploadcareSuccessBlock)successBlock
              failureBlock:(UploadcareFailureBlock)failureBlock {
        
    NSString *const kDataName = @"file"; // whatever goes into multipart form data's name becomes the key for file_id in JSON response
    NSString *uploadFilePath = @"/base/";
    
    /* autodetect content-type if not specified */
    if (!contentType) {
        NSString *fileExtension = [filename pathExtension];
        CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtension, NULL);
        contentType = (__bridge NSString *)UTTypeCopyPreferredTagWithClass(fileUTI, kUTTagClassMIMEType);
        CFRelease(fileUTI);
        NSLog(@"Auto-detected content type: %@", contentType ? contentType : @"Failed to detect");
        if (!contentType)
            contentType = @"";
    }
    
    NSURLRequest *uploadFileRequest = [self.class.sharedUploadClient multipartFormRequestWithMethod:@"POST" path:uploadFilePath parameters:@{
                                          @"UPLOADCARE_PUB_KEY" : self.publicKey } constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                              [formData appendPartWithFileData:data name:kDataName fileName:filename mimeType:contentType];
                                          }];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:uploadFileRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        UploadcareFile *file = [UploadcareFile new];
        file.info = @{@"file_id" : JSON[kDataName], @"original_filename" : filename};
        NSLog(@"%@", file.info);
        successBlock(file);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *requestError, id JSON) {
        NSError *error = [NSError errorWithDomain:UploadcareErrorDomain code:UploadcareErrorConnectingHome userInfo:@{
                       NSLocalizedDescriptionKey : @"Upload request failed",
                            NSUnderlyingErrorKey : requestError
                          }];
        failureBlock(error);
    }];
    
    [operation setUploadProgressBlock:^(NSInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        progressBlock(totalBytesWritten, totalBytesExpectedToWrite);
    }];
    
    [operation start];
}

- (void)uploadFileFromURL:(NSString *)url progressBlock:(UploadcareProgressBlock)progressBlock successBlock:(UploadcareSuccessBlock)successBlock failureBlock:(UploadcareFailureBlock)failureBlock {
    NSString *uploadFromURLPath = [NSString stringWithFormat:@"/from_url/?source_url=%@", url];
    NSURLRequest *uploadFromURLRequest = [self.class.sharedUploadClient requestWithMethod:@"POST" path:uploadFromURLPath parameters:@{
                                          @"pub_key" : self.publicKey }];
    
    AFJSONRequestOperation *operation =
    
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest: uploadFromURLRequest
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         NSString *token = JSON[@"token"];
         [UploadcareStatusWatcher watchUploadWithToken:token progressBlock:progressBlock successBlock:successBlock failureBlock:failureBlock];
     }
     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *requestError, id JSON) {
         NSError *error = [NSError errorWithDomain:UploadcareErrorDomain code:UploadcareErrorConnectingHome userInfo:@{
                        NSLocalizedDescriptionKey : @"Upload request failed",
                             NSUnderlyingErrorKey : requestError
                           }];
         failureBlock(error);
     }];
    [operation start];
}

@end
