//
//  UCClient.m
//  Riders
//
//  Created by Yury Nechaev on 31.03.16.
//  Copyright © 2016 Whitescape. All rights reserved.
//

#import "UCClient.h"
#import "UCClient_Private.h"
#import "UCAPIRequest.h"
#import "UCFileUploadRequest.h"
#import "UCRemoteFileUploadRequest.h"
#import "UCConstantsHeader.h"
#import "NSDictionary+UrlEncoding.h"

static NSString * const UCMultipartPublicKey = @"UPLOADCARE_PUB_KEY";
static NSString * const UCMultipartStoreKey  = @"UPLOADCARE_STORE";
static NSString * const UCParameterPublicKey = @"pub_key";
static NSString * const UCParameterStoreKey  = @"store";

typedef NS_ENUM(NSUInteger, UCStoreOption) {
    UCStoreOptionAutomatic = 0,
    UCStoreOptionYES = 1,
    UCStoreOptionNO = 2
};

@protocol UCMultipartFormDataProtocol <NSObject>

- (void)appendPartWithFileData:(NSData *)data
                          name:(NSString *)name
                      fileName:(NSString *)fileName
                      mimeType:(NSString *)mimeType;

- (void)appendPartWithValue:(NSString *)value
                       name:(NSString *)name;

- (void)appendPartWithPayload:(UCAPIRequestPayload *)payload;

@end

@interface UCMultipartFormData : NSObject <UCMultipartFormDataProtocol>

@property (nonatomic, strong) NSString *boundary;

- (NSUInteger)contentLength;
- (NSData *)bodyByFinalizingMultipartData;

@end

#ifndef NSFoundationVersionNumber_iOS_8_0
#define NSFoundationVersionNumber_With_Fixed_5871104061079552_bug 1140.11
#else
#define NSFoundationVersionNumber_With_Fixed_5871104061079552_bug NSFoundationVersionNumber_iOS_8_0
#endif

static dispatch_queue_t url_session_client_creation_queue() {
    static dispatch_queue_t af_url_session_client_creation_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        af_url_session_client_creation_queue = dispatch_queue_create("com.uploadcare.networking.session.client.creation", DISPATCH_QUEUE_SERIAL);
    });
    
    return af_url_session_client_creation_queue;
}

static void url_session_client_create_task_safely(dispatch_block_t block) {
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_With_Fixed_5871104061079552_bug) {
        // Fix of bug
        // Open Radar:http://openradar.appspot.com/radar?id=5871104061079552 (status: Fixed in iOS8)
        // Issue about:https://github.com/AFNetworking/AFNetworking/issues/2093
        dispatch_sync(url_session_client_creation_queue(), block);
    } else {
        block();
    }
}

#define UC_OBSERVER_RETRY_COUNT 3
#define UC_OBSERVER_REQUEST_INTERVAL 2.0

@interface UCRemoteObserver : NSObject
@property (nonatomic, copy) UCProgressBlock progressBlock;
@property (nonatomic, copy) UCCompletionBlock completionBlock;
@property (nonatomic, strong, readonly) NSString *token;
@property (nonatomic, strong) dispatch_source_t timerSource;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *pollingTask;
@property (nonatomic, assign) NSInteger observerRetryCount;

+ (instancetype)observerWithToken:(NSString *)token
                          session:(NSURLSession *)session
                         progress:(UCProgressBlock)progressBlock
                       completion:(UCCompletionBlock)completionBlock;
@end

@implementation UCRemoteObserver

+ (instancetype)observerWithToken:(NSString *)token
                          session:(NSURLSession *)session
                         progress:(UCProgressBlock)progressBlock
                       completion:(UCCompletionBlock)completionBlock {
    UCRemoteObserver *observer = [[UCRemoteObserver alloc] initWithToken:token session:session progress:progressBlock?:nil completion:completionBlock?:nil];
    return observer;
}

- (id)initWithToken:(NSString *)token
            session:(NSURLSession *)session
           progress:(UCProgressBlock)progress
         completion:(UCCompletionBlock)completion {
    NSParameterAssert(token);
    NSParameterAssert(session);
    self = [super init];
    if (self) {
        _token = token;
        _progressBlock = progress;
        _completionBlock = completion;
        _session = session;
        _observerRetryCount = UC_OBSERVER_RETRY_COUNT;
    }
    return self;
}

- (void)startObsrving {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    double secondsToFire = UC_OBSERVER_REQUEST_INTERVAL;
    
    self.timerSource = CreateDispatchTimer(secondsToFire, queue, ^{
        [self sendPollingRequest];
    });
}

- (void)stopObserving {
    if (self.timerSource) {
        dispatch_source_cancel(self.timerSource);
    }
}

- (id)appropriateResponseObjectFromData:(NSData *)data error:(NSError **)error {
    id result = nil;
    if (data) {
        result = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
        if (error) {
            result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }
    return result ?: data;
}

static NSString * const UCPollingStatusKey = @"status";
static NSString * const UCPollingStatusSuccess = @"success";
static NSString * const UCPollingStatusProgress = @"progress";
static NSString * const UCPollingStatusError = @"error";
static NSString * const UCPollingStatusErrorKey = @"error";
static NSString * const UCPollingStatusDoneBytesKey = @"done";
static NSString * const UCPollingStatusTotalBytesKey = @"total";
static NSString * const UCPollingStatusErrorMessageUnknown = @"Unknown error";

- (void)sendPollingRequest {
    if (self.pollingTask.state == NSURLSessionTaskStateRunning) {
        self.observerRetryCount -= 1;
        if (self.observerRetryCount == 0) {
            [self stopObserving];
            NSError *error = [NSError errorWithDomain:[[self class] errorDomain] code:UCErrorUnknown
                                             userInfo:@{NSLocalizedDescriptionKey : UCPollingStatusErrorMessageUnknown}];
            if (self.completionBlock) self.completionBlock(nil, error);
        }
    }
    __block NSURLSessionDataTask *pollingTask = nil;
    __weak __typeof(self) weakSelf = self;
    url_session_client_create_task_safely(^{
        pollingTask = [self.session dataTaskWithRequest:self.pollingRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            if (!error && data) {
                NSError *jsonError = nil;
                id responseData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                if (responseData) {
                    [strongSelf handleStatusData:responseData];
                } else {
                    [strongSelf stopObserving];
                    [strongSelf handleError:jsonError data:data];
                }
            } else if (error) {
                [strongSelf stopObserving];
                [strongSelf handleError:error data:data];
            }
        }];
    });
    self.pollingTask = pollingTask;
    [self.pollingTask resume];
}

- (void)handleError:(NSError *)error data:(NSData *)data {
    __weak __typeof(self) weakSelf = self;
    if (self.completionBlock) self.completionBlock([weakSelf appropriateResponseObjectFromData:data error:nil], error);
}

- (void)handleStatusData:(id)statusData {
    NSString *status = statusData[UCPollingStatusKey];
    if ([status isEqualToString:UCPollingStatusSuccess]) {
        [self stopObserving];
        if (self.completionBlock) self.completionBlock(statusData, nil);
    } else if ([status isEqualToString:UCPollingStatusError]) {
        [self stopObserving];
        NSError *error = [NSError errorWithDomain:[[self class] errorDomain] code:UCErrorUploadcare
                                         userInfo:@{NSLocalizedDescriptionKey : statusData[UCPollingStatusErrorKey]}];
        if (self.completionBlock) self.completionBlock(statusData, error);
    } else if ([status isEqualToString:UCPollingStatusProgress]) {
        NSUInteger done = [self progressFromValue:statusData withKey:UCPollingStatusDoneBytesKey];
        NSUInteger total = [self progressFromValue:statusData withKey:UCPollingStatusTotalBytesKey];
        if (self.progressBlock) self.progressBlock(done, total);
    }
}

- (NSUInteger)progressFromValue:(id)value withKey:(NSString *)key {
    id progress = value[key];
    if ([progress isKindOfClass:[NSNumber class]]) {
        return [progress unsignedIntegerValue];
    } else {
        return NSUIntegerMax;
    }
}

+ (NSString *)errorDomain {
    return [@[UCRootDomain, UCRemoteFileUploadDomain] componentsJoinedByString:@"."];
}

static NSString * const UCFileTokenKey = @"token";

- (NSURLRequest *)pollingRequest {
    NSURLComponents *components = [NSURLComponents new];
    [components setScheme:UCAPIProtocol];
    [components setHost:UCApiRoot];
    [components setPath:UCRemoteObservingPath];
    [components setQuery:@{UCFileTokenKey: self.token}.uc_urlOriginalString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[components URL]];
    return request;
}

dispatch_source_t CreateDispatchTimer(double interval, dispatch_queue_t queue, dispatch_block_t block)
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (timer)
    {
        dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
    }
    return timer;
}

@end

@interface UCClient () <NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSString *publicKey;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSession *pollingSession;
@property (nonatomic, strong) NSMutableDictionary *responsesData;
@property (nonatomic, assign) UCStoreOption storeOption;
@property (nonatomic, strong) NSMutableArray *pollingTasks;
@property (nonatomic, strong) UCRemoteObserver *remoteObserver;
@property (nonatomic, strong) NSMutableDictionary *completionQueue;
@property (nonatomic, strong) NSMutableDictionary *progressQueue;
@property (nonatomic, strong) NSCache *cache;
@end

static UCClient *instanceClient = nil;

@implementation UCClient

+ (instancetype)defaultClient {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instanceClient = [[UCClient alloc] init];
    });
    return instanceClient;
}

- (NSCache *)cache {
    if (!_cache) {
        _cache = [[NSCache alloc] init];
    }
    return _cache;
}

- (void)setPublicKey:(NSString *)publicKey {
    _publicKey = publicKey;
}

- (void)authorizeMultipartApiRequest:(UCAPIRequest *)apiRequest {
    [self authorizeRequest:apiRequest
            withParameters:@{UCMultipartPublicKey: self.publicKey,
                             UCMultipartStoreKey: self.currentStoragePolitics}];
}

- (void)authorizeApiRequest:(UCAPIRequest *)apiRequest {
    [self authorizeRequest:apiRequest
            withParameters:@{UCParameterPublicKey: self.publicKey,
                             UCParameterStoreKey: self.currentStoragePolitics}];
}

- (void)authorizeRequest:(UCAPIRequest *)apiRequest
          withParameters:(NSDictionary *)parameters {
    NSMutableDictionary *params = apiRequest.parameters.mutableCopy;
    if (!params) params = [NSMutableDictionary new];
    [params addEntriesFromDictionary:parameters];
    apiRequest.parameters = params.copy;
}

- (UCMultipartFormData *)dataFromFileUploadRequest:(UCFileUploadRequest *)fileRequest {
    NSMutableDictionary *params = fileRequest.parameters.mutableCopy;
    UCMultipartFormData *formData = [UCMultipartFormData new];
    for (NSString *key in params) {
        [formData appendPartWithValue:params[key] name:key];
    }
    if (fileRequest.payload) {
        [formData appendPartWithPayload:fileRequest.payload];
    }
    return formData;
}

- (void)addMultipartHeadersForRequest:(NSMutableURLRequest *)request boundary:(NSString *)boundary contentLength:(NSUInteger)conentLength {
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)conentLength];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
}

- (NSURLSessionDataTask *)performUCRequest:(UCAPIRequest *)ucRequest
                                    progress:(UCProgressBlock)progressBlock
                                  completion:(UCCompletionBlock)completionBlock {
    __block NSURLSessionDataTask *task = nil;
    
    if ([ucRequest isKindOfClass:[UCFileUploadRequest class]]) {
        
        [self authorizeMultipartApiRequest:ucRequest];
        
        UCFileUploadRequest *fileRequest = (UCFileUploadRequest *)ucRequest;
        UCMultipartFormData *bodyData = [self dataFromFileUploadRequest:fileRequest];
        
        NSMutableURLRequest *urlRequest = [ucRequest request];
        
        [self addMultipartHeadersForRequest:urlRequest
                                   boundary:bodyData.boundary
                              contentLength:bodyData.contentLength];
        
        task = [self uploadTaskWithRequest:urlRequest data:[bodyData bodyByFinalizingMultipartData]];
        
        [self launchTask:task progress:progressBlock completion:completionBlock];
    } else {
        
        [self authorizeApiRequest:ucRequest];

        NSMutableURLRequest *urlRequest = [ucRequest request];
        
        task = [self dataTaskWithRequest:urlRequest completion:nil];
        
        if ([ucRequest isKindOfClass:[UCRemoteFileUploadRequest class]]) {
            [self.pollingTasks addObject:@(task.taskIdentifier)];
        }
        [self launchTask:task progress:progressBlock completion:completionBlock];
    }
    
    return task;
}

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request data:(NSData *)data {
    __block NSURLSessionUploadTask *task = nil;
    url_session_client_create_task_safely(^{
        task = [self.session uploadTaskWithRequest:request fromData:data];
    });
    return task;
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                                   completion:(void (^)(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error))completionHandler {
    __block NSURLSessionDataTask *task = nil;
    url_session_client_create_task_safely(^{
        if (completionHandler) {
            task = [self.session dataTaskWithRequest:request];
        } else {
            task = [self.session dataTaskWithRequest:request completionHandler:completionHandler];
        }
    });
    return task;
}

- (void)launchTask:(NSURLSessionDataTask *)task
          progress:(UCProgressBlock)progress
        completion:(UCCompletionBlock)completion {
    if (progress) [self storeProgress:progress forTaskID:task.taskIdentifier];
    if (completion) [self storeCompletion:completion forTaskID:task.taskIdentifier];
    [task resume];
}

- (void)storeCompletion:(UCCompletionBlock)completionBlock forTaskID:(NSUInteger)taskID {
    @synchronized (self.completionQueue) {
        [self.completionQueue setObject:completionBlock forKey:@(taskID)];
    }
}

- (void)storeProgress:(UCProgressBlock)progressBlock forTaskID:(NSUInteger)taskID {
    @synchronized (self.progressQueue) {
        [self.progressQueue setObject:progressBlock forKey:@(taskID)];
    }
}

#pragma mark - Lazy initializers

- (NSURLSession *)pollingSession {
    if (!_pollingSession) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _pollingSession = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:nil];
    }
    return _pollingSession;
}

- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    }
    return _session;
}

- (NSMutableArray *)pollingTasks {
    if (!_pollingTasks) {
        _pollingTasks = @[].mutableCopy;
    }
    return _pollingTasks;
}

- (NSMutableDictionary *)completionQueue {
    if (!_completionQueue) {
        _completionQueue = [NSMutableDictionary new];
    }
    return _completionQueue;
}

- (NSMutableDictionary *)progressQueue {
    if (!_progressQueue) {
        _progressQueue = [NSMutableDictionary new];
    }
    return _progressQueue;
}

- (NSMutableDictionary *)responsesData {
    if (!_responsesData) {
        _responsesData = [NSMutableDictionary new];
    }
    return _responsesData;
}

#pragma mark - NSURLSession delegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSData *existingData = self.responsesData[@(dataTask.taskIdentifier)];
    if (existingData) {
        NSMutableData *mutableData = existingData.mutableCopy;
        [mutableData appendData:data];
        self.responsesData[@(dataTask.taskIdentifier)] = mutableData.copy;
    } else {
        self.responsesData[@(dataTask.taskIdentifier)] = data;
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    UCProgressBlock progressBlock = [self.progressQueue objectForKey:@(task.taskIdentifier)];
    if (progressBlock) progressBlock(totalBytesSent, totalBytesExpectedToSend);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    id response = self.responsesData[@(task.taskIdentifier)];
    UCCompletionBlock completionBlock = [self.completionQueue objectForKey:@(task.taskIdentifier)];
    UCProgressBlock progressBlock = [self.progressQueue objectForKey:@(task.taskIdentifier)];

    NSError *jsonError = nil;
    id responseJson = nil;
    if (response) responseJson = [NSJSONSerialization JSONObjectWithData:response options:0 error:&jsonError];
    
    if (!error && [self.pollingTasks containsObject:@(task.taskIdentifier)]) {
        @synchronized (self.pollingTasks) {
            [self.pollingTasks removeObject:@(task.taskIdentifier)];
        }
        if (jsonError || !responseJson) {
            if (completionBlock) completionBlock (responseJson ?: response, jsonError);
            [self removeQueuesForTaskId:task.taskIdentifier];
        } else {
            self.remoteObserver = [UCRemoteObserver observerWithToken:responseJson[@"token"] session:self.pollingSession progress:progressBlock completion:completionBlock];
            [self.remoteObserver startObsrving];
        }
    } else {
        if (completionBlock) completionBlock (responseJson, responseJson ? error : jsonError);
        [self removeQueuesForTaskId:task.taskIdentifier];
    }
    
    [self.responsesData removeObjectForKey:@(task.taskIdentifier)];
}

#pragma mark - Utilities

- (NSString *)currentStoragePolitics {
    NSString *returnedValue = nil;
    switch (self.storeOption) {
        case UCStoreOptionAutomatic: {
            returnedValue = @"auto";
            break;
        }
        case UCStoreOptionYES: {
            returnedValue = @"1";
            break;
        }
        case UCStoreOptionNO: {
            returnedValue = @"0";
            break;
        }
    }
    return returnedValue;
}

- (void)removeQueuesForTaskId:(NSUInteger)taskId {
    @synchronized (self.completionQueue) {
        [self.completionQueue removeObjectForKey:@(taskId)];
    }
    @synchronized (self.progressQueue) {
        [self.progressQueue removeObjectForKey:@(taskId)];
    }
}

@end

@interface UCMultipartFormData ()
@property (nonatomic, strong) NSMutableData *multipartData;
@end


@implementation UCMultipartFormData

- (id)init {
    self = [super init];
    if (self) {
        _multipartData = [NSMutableData new];
        _boundary = UCCreateMultipartFormBoundary();
    }
    return self;
}

- (void)appendPartWithPayload:(UCAPIRequestPayload *)payload {
    [self appendPartWithFileData:payload.payload
                            name:payload.name
                        fileName:payload.fileName
                        mimeType:payload.mimeType];
}

- (void)appendPartWithFileData:(NSData *)data
                          name:(NSString *)name
                      fileName:(NSString *)fileName
                      mimeType:(NSString *)mimeType {
    [self.multipartData appendData:[UCMultipartFormInitialBoundary(self.boundary) dataUsingEncoding:NSUTF8StringEncoding]];
    [self.multipartData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"%@", name, fileName, UCMultipartFormCRLF] dataUsingEncoding:NSUTF8StringEncoding]];
    [self.multipartData appendData:[[NSString stringWithFormat:@"Content-Type: %@%@%@", mimeType, UCMultipartFormCRLF, UCMultipartFormCRLF] dataUsingEncoding:NSUTF8StringEncoding]];
    [self.multipartData appendData:data];
    [self.multipartData appendData:[UCMultipartFormCRLF dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)appendPartWithValue:(NSString *)value
                       name:(NSString *)name {
    [self.multipartData appendData:[UCMultipartFormInitialBoundary(self.boundary) dataUsingEncoding:NSUTF8StringEncoding]];
    [self.multipartData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"%@%@", name, UCMultipartFormCRLF, UCMultipartFormCRLF] dataUsingEncoding:NSUTF8StringEncoding]];
    [self.multipartData appendData:[[NSString stringWithFormat:@"%@%@", value, UCMultipartFormCRLF] dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSData *)bodyByFinalizingMultipartData {
    NSMutableData *data = [self.multipartData mutableCopy];
    
    [data appendData:[UCMultipartFormFinalBoundary(self.boundary)
                      dataUsingEncoding:NSUTF8StringEncoding]];
    return [data copy];
}

- (NSUInteger)contentLength {
    return [[self bodyByFinalizingMultipartData] length];
}

#pragma mark - Utilities

static NSString * UCCreateMultipartFormBoundary() {
    return [NSString stringWithFormat:@"boundary+%08X%08X", arc4random(), arc4random()];
}

static NSString * const UCMultipartFormCRLF = @"\r\n";

static inline NSString * UCMultipartFormInitialBoundary(NSString *boundary) {
    return [NSString stringWithFormat:@"--%@%@", boundary, UCMultipartFormCRLF];
}

static inline NSString * UCMultipartFormFinalBoundary(NSString *boundary) {
    return [NSString stringWithFormat:@"%@--%@--%@", UCMultipartFormCRLF, boundary, UCMultipartFormCRLF];
}

@end

