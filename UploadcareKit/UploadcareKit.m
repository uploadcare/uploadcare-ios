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

NSString * const UploadcareBaseUploadURL = @"https://upload.uploadcare.com";

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
         
- (id)init {
    if (self = [super init]) {
        [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObjects:@"application/vnd.uploadcare-v0.2+json", nil]];
        [UploadcareStatusWatcher preheatPusher];
    }
    return self;
}

#pragma mark - Upload

- (void)uploadFileNamed:(NSString *)filename
            contentData:(NSData *)data
            contentType:(NSString *)contentType
          progressBlock:(UploadcareProgressBlock)progressBlock
           successBlock:(UploadcareSuccessBlock)successBlock
           failureBlock:(UploadcareFailureBlock)failureBlock {
    
    NSString *const kDataFileId = @"file"; // whatever goes into multipart form data's name becomes the key for the file id in JSON response dict.
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
    
    /* upload! */
    NSURLRequest *uploadFileRequest = [self.class.sharedUploadClient multipartFormRequestWithMethod:@"POST" path:uploadFilePath parameters:@{
                                          @"UPLOADCARE_PUB_KEY" : self.publicKey } constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                              [formData appendPartWithFileData:data name:kDataFileId fileName:filename mimeType:contentType];
                                          }];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:uploadFileRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        /* request succeeded */
        NSString *fileId = JSON[kDataFileId];
        successBlock(fileId);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *requestError, id JSON) {
        /* request failed */
        NSError *error;
        
        if (response.statusCode == 403)
            error = UploadcareMakePubAuthError(requestError);
        else
            error = [NSError errorWithDomain:UploadcareErrorDomain code:UploadcareErrorConnectingHome userInfo:@{NSLocalizedDescriptionKey:@"Upload request failed.", NSLocalizedFailureReasonErrorKey:[NSHTTPURLResponse localizedStringForStatusCode:response.statusCode], NSUnderlyingErrorKey:requestError}];
        
        failureBlock(error);
    }];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        progressBlock(totalBytesWritten, totalBytesExpectedToWrite);
    }];

    /* Allow the upload to continue in the background */
    [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
        /* do nothing */
    }];
    
    [operation start];
}

- (void)uploadFileFromURL:(NSString *)url
            progressBlock:(UploadcareProgressBlock)progressBlock
             successBlock:(UploadcareSuccessBlock)successBlock
             failureBlock:(UploadcareFailureBlock)failureBlock {
    
    NSString *uploadFromURLPath = @"/from_url/";
    NSURLRequest *uploadFromURLRequest = [self.class.sharedUploadClient requestWithMethod:@"POST" path:uploadFromURLPath parameters:@{
                                          @"pub_key" : self.publicKey,
                                          @"source_url" : url }];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:uploadFromURLRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        /* request succeeded */
        NSString *token = JSON[@"token"];
        [UploadcareStatusWatcher watchUploadWithToken:token progressBlock:progressBlock successBlock:successBlock failureBlock:failureBlock];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *requestError, id JSON) {
        /* request failed */
        
        NSError *error;
        if (response.statusCode == 403)
            error = UploadcareMakePubAuthError(requestError);
        else
            error = [NSError errorWithDomain:UploadcareErrorDomain code:UploadcareErrorConnectingHome userInfo:@{NSLocalizedDescriptionKey:@"Upload request failed.", NSLocalizedFailureReasonErrorKey:[NSHTTPURLResponse localizedStringForStatusCode:response.statusCode], NSUnderlyingErrorKey:requestError}];
        
        failureBlock(error);
    }];
    
    /* This doesn't make much sense, since the request is expected to yield
     * immediately, as the actual uploading runs on the server only. Still,
     * won't hurt to be on the safer side. */
    [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
        /* do nothing */
    }];

    
    [operation start];
}

@end
