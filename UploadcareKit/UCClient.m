//
//  UCClient.m
//  Riders
//
//  Created by Yury Nechaev on 31.03.16.
//  Copyright © 2016 Whitescape. All rights reserved.
//

#import "UCClient.h"
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

@interface UCRemoteObserver : NSObject
@property (nonatomic, copy) UCProgressBlock progressBlock;
@property (nonatomic, copy) UCCompletionBlock completionBlock;
@property (nonatomic, strong, readonly) NSString *token;
@property (nonatomic, strong) dispatch_source_t timerSource;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *pollingTask;

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
    UCRemoteObserver *observer = [[UCRemoteObserver alloc] initWithToken:token session:session progress:progressBlock completion:completionBlock];
    return observer;
}

- (id)initWithToken:(NSString *)token
            session:(NSURLSession *)session
           progress:(UCProgressBlock)progress
         completion:(UCCompletionBlock)completion {
    self = [super init];
    if (self) {
        _token = token;
        _progressBlock = progress;
        _completionBlock = completion;
        _session = session;
    }
    return self;
}

- (void)startObsrving {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    double secondsToFire = 2.000f;
    
    self.timerSource = CreateDispatchTimer(secondsToFire, queue, ^{
        [self sendPollingRequest];
    });
}

- (void)stopObserving {
    if (self.timerSource) {
        dispatch_source_cancel(self.timerSource);
    }
}

- (void)sendPollingRequest {
    if (self.pollingTask.state == NSURLSessionTaskStateRunning) [self.pollingTask cancel];
    self.pollingTask = [self.session dataTaskWithRequest:self.pollingRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error && data) {
            NSError *jsonError = nil;
            id responseData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            NSString *status = responseData[@"status"];
            if ([status isEqualToString:@"success"]) {
                [self stopObserving];
                if (self.completionBlock) self.completionBlock(self.pollingTask.taskIdentifier, data, error);
            } else if ([status isEqualToString:@"error"]) {
                [self stopObserving];
                NSError *error = [NSError errorWithDomain:self.errorDomain code:2001 userInfo:@{NSLocalizedDescriptionKey : responseData[@"error"]}];
                if (self.completionBlock) self.completionBlock(self.pollingTask.taskIdentifier, data, error);
            } else if ([status isEqualToString:@"progress"]) {
                NSUInteger done = [responseData[@"done"] unsignedIntegerValue];
                NSUInteger total = [responseData[@"total"] unsignedIntegerValue];
                if (self.progressBlock) self.progressBlock(self.pollingTask.taskIdentifier, done, done, total);
            }
        }
    }];
    [self.pollingTask resume];
}

- (NSString *)errorDomain {
    return [@[UCRootDomain, UCRemoteFileUploadDomain] componentsJoinedByString:@"."];
}

- (NSURLRequest *)pollingRequest {
    NSURLComponents *components = [NSURLComponents new];
    [components setScheme:UCAPIProtocol];
    [components setHost:UCApiRoot];
    [components setPath:UCRemoteObservingPath];
    [components setQuery:@{@"token": self.token}.urlOriginalString];
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
@property (nonatomic, strong) NSMutableDictionary *responsesData;
@property (nonatomic, assign) UCStoreOption storeOption;
@property (nonatomic, strong) NSMutableArray *pollingTasks;
@property (nonatomic, strong) UCRemoteObserver *remoteObserver;

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
    NSString *postLength = [NSString stringWithFormat:@"%d", conentLength];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
}

- (NSURLSessionDataTask *)performUCRequest:(UCAPIRequest *)ucRequest
                                    progress:(UCProgressBlock)progressBlock
                                  completion:(UCCompletionBlock)completionBlock {
    
    _completionBlock = completionBlock;
    _progressBlock = progressBlock;
    
    
    NSURLSessionDataTask *task = nil;
    
    if ([ucRequest isKindOfClass:[UCFileUploadRequest class]]) {
        
        [self authorizeMultipartApiRequest:ucRequest];
        
        UCFileUploadRequest *fileRequest = (UCFileUploadRequest *)ucRequest;
        UCMultipartFormData *bodyData = [self dataFromFileUploadRequest:fileRequest];
        
        NSMutableURLRequest *urlRequest = [ucRequest request];
        
        [self addMultipartHeadersForRequest:urlRequest
                                   boundary:bodyData.boundary
                              contentLength:bodyData.contentLength];
        
        task = [self.session uploadTaskWithRequest:urlRequest fromData:[bodyData bodyByFinalizingMultipartData]];
        [task resume];
    } else {
        
        [self authorizeApiRequest:ucRequest];

        NSMutableURLRequest *urlRequest = [ucRequest request];
        
        task = [self.session dataTaskWithRequest:urlRequest];
        
        if ([ucRequest isKindOfClass:[UCRemoteFileUploadRequest class]]) {
            [self.pollingTasks addObject:@(task.taskIdentifier)];
        }
        
        [task resume];
    }
    
    return task;
}

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

- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    }
    return _session;
}

#pragma mark - lazy initializers

- (NSMutableArray *)pollingTasks {
    if (!_pollingTasks) {
        _pollingTasks = @[].mutableCopy;
    }
    return _pollingTasks;
}

- (NSMutableDictionary *)responsesData {
    if (!_responsesData) {
        _responsesData = [NSMutableDictionary new];
    }
    return _responsesData;
}

#pragma mark - NSURLSession delegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSMutableData *responseData = self.responsesData[@(dataTask.taskIdentifier)];
    if (!responseData) {
        responseData = [NSMutableData dataWithData:data];
        self.responsesData[@(dataTask.taskIdentifier)] = responseData;
    } else {
        [responseData appendData:data];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    if (self.progressBlock) self.progressBlock(task.taskIdentifier, bytesSent, totalBytesSent, totalBytesExpectedToSend);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    id response = self.responsesData[@(task.taskIdentifier)];
    if (!error && [self.pollingTasks containsObject:@(task.taskIdentifier)]) {
        NSError *jsonError = nil;
        id responseJson = [NSJSONSerialization JSONObjectWithData:response options:0 error:&jsonError];
        
        if (jsonError) {
            if (self.completionBlock) self.completionBlock (task.taskIdentifier, response, jsonError);
        }
        
        self.remoteObserver = [UCRemoteObserver observerWithToken:responseJson[@"token"] session:self.session progress:self.progressBlock completion:self.completionBlock];
        [self.remoteObserver startObsrving];
        
    } else {
        if (self.completionBlock) self.completionBlock (task.taskIdentifier, response, error);
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

- (NSUInteger)contentLength {
    return [[self bodyByFinalizingMultipartData] length];
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

