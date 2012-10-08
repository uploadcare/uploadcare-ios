//
//  UploadcareStatusWatcher.m
//  UploadcareKit
//
//  Created by Zoreslav Khimich on 10/8/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UploadcareKit.h"
#import "UploadcareStatusWatcher.h"
#import "PTPusher.h"
#import "PTPusherChannel.h"
#import "PTPusherEvent.h"
#import "AFJSONRequestOperation.h"

static NSString *const UPLOADCARE_PUSHER_KEY = @"79ae88bd931ea68464d9";

/* TODO: move out */
NSString *const UPLOADCARE_ERROR_DOMAIN = @"UploadCare";
const int UPLOADCARE_ERROR_UPLOAD_FROM_URL_FAILED = 0x1001;

@interface UploadcareStatusWatcher ()

@property NSString *token;
@property PTPusher *pusher;
@property NSTimeInterval pusherTimeout;

@property (strong) UCSWUploadProgressBlock progressBlock;
@property (strong) UCSWUploadSuccessBlock successBlock;
@property (strong) UCSWUploadFailureBlock failureBlock;

@end

#pragma mark -

@implementation UploadcareStatusWatcher

- (id)initWithToken: (NSString *)token progressBlock:(UCSWUploadProgressBlock)progressBlock successBlock:(UCSWUploadSuccessBlock)successBlock failureBlock:(UCSWUploadFailureBlock)failureBlock {
    self = [super init];
    if (self) {
        _token = token;
        _progressBlock = progressBlock;
        _successBlock = successBlock;
        _failureBlock = failureBlock;
        
        /* pusher */
        _pusher = [PTPusher pusherWithKey:UPLOADCARE_PUSHER_KEY delegate:self encrypted:YES];
        _pusher.reconnectAutomatically = YES;
        _pusher.reconnectDelay = .5; // default = 5
        PTPusherChannel *channel = [_pusher subscribeToChannelNamed:[NSString stringWithFormat:@"task-status-%@", _token]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePusherEvent:) name:PTPusherEventReceivedNotification object:channel];
        
        /* time-out */
        _pusherTimeout = 1.0;
        
        /* poller */
        [self scheduleFallBackPoll];
    }
    return self;
}

#pragma mark - Pusher

- (void)didReceivePusherEvent:(NSNotification *)notification {
    /* cancel the scheduled fall-back poll */
    [NSObject cancelPreviousPerformRequestsWithTarget:self]; /* warning: this removes stuff from the current run loop only */
    
    PTPusherEvent *pusherEvent = notification.userInfo[PTPusherEventUserInfoKey];
    [self processUploadStatus:pusherEvent.name withDetails:pusherEvent.data];
    
    /* re-schedule the fall-back poll */
    [self scheduleFallBackPoll];
}


#pragma mark - Poll

- (void)scheduleFallBackPoll {
    [self performSelector:@selector(poll) withObject:nil afterDelay:_pusherTimeout]; /* TODO: sort out run loops */
}

- (void)poll {
    NSURLRequest *statusRequest = [NSURLRequest requestWithURL:[NSURL URLWithString: API_UPLOAD @"/status/"]];
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:statusRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        /* get /status/ success */
        NSString *status = JSON[@"status"];
        [self processUploadStatus:status withDetails:JSON];
        [self scheduleFallBackPoll]; // re-schedule self
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        /* get /status/ failed */
        [self didReceiveUploadError:error];
    }];
    [op start];
}


#pragma mark - Shared (pusher/poller)

- (void)processUploadStatus:(NSString *)statusName withDetails:(id)data {
    if ([statusName isEqualToString:@"progress"]) {
        /* progress */
        long long bytesDone = [data[@"done"] longLongValue];
        long long bytesTotal = [data[@"total"] longLongValue];
        [self didReceiveProgressInBytes:bytesDone ofTotal:bytesTotal];
    } else if ([statusName isEqualToString:@"success"]) {
        /* success */
        [self didReceiveUploadSuccessWithDetails:data];
    } else if ([statusName isEqualToString:@"error"] || [statusName isEqualToString:@"fail"]) {
        /* error */
        [self didReceiveUploadError:[NSError errorWithDomain:UPLOADCARE_ERROR_DOMAIN code:UPLOADCARE_ERROR_UPLOAD_FROM_URL_FAILED userInfo:data]];
    } else {
        NSLog(@"Unknown upload status: %@", statusName);
    }
}

- (void)didReceiveProgressInBytes:(long long)uploadedBytes ofTotal:(long long)totalBytes {
    if (uploadedBytes == totalBytes == 0)
        return;
    self.progressBlock(uploadedBytes, totalBytes);
}

- (void)didReceiveUploadSuccessWithDetails:(id)data {
    UploadcareFile *file = [UploadcareFile new];
    file.info = data;
    self.successBlock(data);
    [self removeFromTheWatch];
}

- (void)didReceiveUploadError:(NSError *)error {
    self.failureBlock(error);
    [self removeFromTheWatch];
}

#pragma mark - Lifecycle and ownership

- (void)removeFromTheWatch {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.pusher disconnect];
    [[self.class watchers] removeObjectForKey:self.token];
}

+ (NSMutableDictionary *)watchers {
    static NSMutableDictionary *_watchers = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _watchers = [[NSMutableDictionary alloc]initWithCapacity:2];
    });
    return _watchers;
}

+ (id)watchUploadWithToken:(NSString *)token progressBlock:(UCSWUploadProgressBlock)progressBlock successBlock:(UCSWUploadSuccessBlock)successBlock failureBlock:(UCSWUploadFailureBlock)failureBlock{
    UploadcareStatusWatcher *watcher = [[UploadcareStatusWatcher alloc]initWithToken:token progressBlock:progressBlock successBlock:successBlock failureBlock:failureBlock];
    [[self watchers] setObject:watcher forKey:token];
    return watcher;
}

@end
