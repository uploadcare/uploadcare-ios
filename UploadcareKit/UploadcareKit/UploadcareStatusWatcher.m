//
//  UploadcareStatusWatcher.m
//  UploadcareKit
//
//  Created by Zoreslav Khimich on 10/8/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UploadcareKit.h"
#import "UploadcareFile.h"
#import "UploadcareStatusWatcher.h"
#import "PTPusher.h"
#import "PTPusherChannel.h"
#import "PTPusherEvent.h"
#import "AFJSONRequestOperation.h"

static NSString *const UPLOADCARE_PUSHER_KEY = @"79ae88bd931ea68464d9";

static const NSTimeInterval UCSWPusherTimeout = 2.;     // if the Pusher is still not working after this amount of time, poll will start
static const NSTimeInterval UCSWPollRate = 1. / 4;

/* TODO: move somewhere else */
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
        _pusher = [self.class sharedPusher];
        _pusher.reconnectAutomatically = YES;
        _pusher.reconnectDelay = .5; // default = 5
        PTPusherChannel *channel = [_pusher subscribeToChannelNamed:[NSString stringWithFormat:@"task-status-%@", _token]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePusherEvent:) name:PTPusherEventReceivedNotification object:channel];
        
        _pusherTimeout = UCSWPusherTimeout;
        
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

    [self setPusherTimeout:UCSWPusherTimeout];
    [self processUploadStatus:pusherEvent.name withDetails:pusherEvent.data];
}


#pragma mark - Poll

- (void)scheduleFallBackPoll {
    [self performSelector:@selector(poll) withObject:nil afterDelay:_pusherTimeout]; /* TODO: sort out run loops */
}

- (void)poll {
    NSURLRequest *statusRequest = [NSURLRequest requestWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@/status/?token=%@", API_UPLOAD, self.token]]];
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:statusRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        /* get /status/ success */
        NSString *status = JSON[@"status"];
        if (!status && JSON[@"error"]) { /* handle {'error': 'All wrong'} cases */
            status = @"error";
        }
        [self setPusherTimeout:UCSWPollRate];
        [self processUploadStatus:status withDetails:JSON];
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
        /* re-schedule the fall-back poll */
        [self scheduleFallBackPoll];
    } else if ([statusName isEqualToString:@"success"]) {
        /* success */
        [self didReceiveUploadSuccessWithDetails:data];
    } else if ([statusName isEqualToString:@"error"] || [statusName isEqualToString:@"fail"]) {
        /* error */
        [self didReceiveUploadError:[NSError errorWithDomain:UPLOADCARE_ERROR_DOMAIN code:UPLOADCARE_ERROR_UPLOAD_FROM_URL_FAILED userInfo:data]];
    } else {
        /* unknown status */
        [self scheduleFallBackPoll];
    }
}

- (void)didReceiveProgressInBytes:(long long)uploadedBytes ofTotal:(long long)totalBytes {
    self.progressBlock(uploadedBytes, totalBytes);
}

- (void)didReceiveUploadSuccessWithDetails:(id)data {
    UploadcareFile *file = [UploadcareFile new];
    file.info = data;
    self.successBlock(file);
    [self removeFromTheWatch];
}

- (void)didReceiveUploadError:(NSError *)error {
    self.failureBlock(error);
    [self removeFromTheWatch];
}

#pragma mark - Lifecycle and ownership

- (void)removeFromTheWatch {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
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

+ (PTPusher *)sharedPusher {
    static PTPusher *_pusher = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _pusher = [PTPusher pusherWithKey:UPLOADCARE_PUSHER_KEY connectAutomatically:YES encrypted:YES];
        // TODO: delegate
    });
    return _pusher;
}

+ (void)preheatPusher {
    [self sharedPusher];
}

@end
