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

@interface UploadcareKit ()

@property (strong, atomic) AFHTTPClient *client;

@end

    
@implementation UploadcareKit

@synthesize publicKey = _publicKey;

- (id)init {
    
    self = [super init];
    
    if (!self)
        return nil;
    
    _client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:UploadcareBaseUploadURL]];
    
    [_client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [_client setDefaultHeader:@"Accept" value:@"application/vnd.uploadcare-v0.2+json"];
    
    [UploadcareStatusWatcher preheatPusher]; /* XXX Do we need this? */
    
    return self;
    
}


- (NSString *)publicKey {
    
    if (!_publicKey)
        [NSException raise:UploadcareMissingPublicKeyException format:@"publicKey property must be set. You can get your public key from https://uploadcare.com/accounts/settings/"];
    
    return _publicKey;
    
}

+ (UploadcareKit *)shared {

    static id _sharedObject = nil;

    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        
        _sharedObject = [[self alloc] init];
        
    });
    
    return _sharedObject;
    
}

#pragma mark - Upload

- (void)uploadFileNamed:(NSString *)filename
            contentData:(NSData *)data
            contentType:(NSString *)contentType
          progressBlock:(UploadcareProgressBlock)progressBlock
           successBlock:(UploadcareSuccessBlock)successBlock
           failureBlock:(UploadcareFailureBlock)failureBlock {
    
    [self startUploadingData:data withName:filename contentType:contentType store:NO progressBlock:progressBlock successBlock:successBlock failureBlock:failureBlock];
    
}

- (NSOperation *)startUploadingData:(NSData *)data withName:(NSString *)filename contentType:(NSString *)contentTypeOrNil store:(BOOL)shouldStore progressBlock:(UploadcareProgressBlock)progressBlock successBlock:(UploadcareSuccessBlock)successBlock failureBlock:(UploadcareFailureBlock)failureBlock {
    
    NSString *const kDataFileId = @"file";
    NSString *uploadFilePath = @"/base/";
    
    /* autodetect content-type if not specified */
    
    if (!contentTypeOrNil) {
        
        NSString *fileExtension = [filename pathExtension];
        
        CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtension, NULL);
        
        contentTypeOrNil = (__bridge NSString *)UTTypeCopyPreferredTagWithClass(fileUTI, kUTTagClassMIMEType);
        
        CFRelease(fileUTI);
        
        if (!contentTypeOrNil)
            contentTypeOrNil = @"";
        
    }
    
    NSURLRequest *uploadFileRequest = [self.client multipartFormRequestWithMethod:@"POST" path:uploadFilePath parameters:@{ @"UPLOADCARE_PUB_KEY" : self.publicKey, @"UPLOADCARE_STORE" : @(shouldStore) } constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:data name:kDataFileId fileName:filename mimeType:contentTypeOrNil];
        
    }];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:uploadFileRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        /* request succeeded */
        NSString *fileId = JSON[kDataFileId];
        successBlock(fileId);
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *requestError, id JSON) {
        
        /* request failed */
        NSError *error;
        
        if (response.statusCode == 403) {
            
            error = UploadcareMakePubAuthError(requestError);

        } else {
            
            error = [NSError errorWithDomain:UploadcareErrorDomain code:UploadcareErrorConnectingHome userInfo:@{NSLocalizedDescriptionKey:@"Upload request failed.", NSLocalizedFailureReasonErrorKey:[NSHTTPURLResponse localizedStringForStatusCode:response.statusCode], NSUnderlyingErrorKey:requestError}];
            
        }
        
        failureBlock(error);
        
    }];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        
        progressBlock(totalBytesWritten, totalBytesExpectedToWrite);
        
    }];
    
    /* Allow the upload to continue in the background */
    [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
        
        NSError *error = [NSError errorWithDomain:UploadcareErrorDomain code:UploadcareErrorBackgroundUploadExpired userInfo:@{NSLocalizedDescriptionKey:@"Background upload expired"}];
        
        failureBlock(error);
        
    }];
    
    [operation start];
    
    return operation;
    
}

- (void)uploadFileFromURL:(NSString *)url
            progressBlock:(UploadcareProgressBlock)progressBlock
             successBlock:(UploadcareSuccessBlock)successBlock
             failureBlock:(UploadcareFailureBlock)failureBlock {
    
    [self startUploadingFromURL:[NSURL URLWithString:url] store:NO progressBlock:progressBlock successBlock:successBlock failureBlock:failureBlock];
    
}

- (NSOperation *)startUploadingFromURL:(NSURL *)url store:(BOOL)shouldStore progressBlock:(UploadcareProgressBlock)progressBlock successBlock:(UploadcareSuccessBlock)successBlock failureBlock:(UploadcareFailureBlock)failureBlock {
    
    NSString *uploadFromURLPath = @"/from_url/";
    
    NSURLRequest *uploadFromURLRequest = [self.client requestWithMethod:@"POST" path:uploadFromURLPath parameters:@{ @"pub_key" : self.publicKey, @"source_url" : url.absoluteString }];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:uploadFromURLRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        /* request succeeded */

        NSString *token = JSON[@"token"];
        
        [UploadcareStatusWatcher watchUploadWithToken:token progressBlock:progressBlock successBlock:successBlock failureBlock:failureBlock];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *requestError, id JSON) {

        /* request failed */
        
        NSError *error;
        if (response.statusCode == 403) {
            
            error = UploadcareMakePubAuthError(requestError);

        } else {
        
            error = [NSError errorWithDomain:UploadcareErrorDomain code:UploadcareErrorConnectingHome userInfo:@{NSLocalizedDescriptionKey:@"Upload request failed.", NSLocalizedFailureReasonErrorKey:[NSHTTPURLResponse localizedStringForStatusCode:response.statusCode], NSUnderlyingErrorKey:requestError}];

        }
        
        failureBlock(error);
        
    }];
    
    [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
        
        NSError *error = [NSError errorWithDomain:UploadcareErrorDomain code:UploadcareErrorBackgroundUploadExpired userInfo:@{NSLocalizedDescriptionKey:@"Background upload expired"}];
        
        failureBlock(error);
        
    }];
    
    [operation start];
    
    return operation;
    
}


@end
