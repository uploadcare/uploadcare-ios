//
//  UploadcareStatusWatcher.m
//  UploadcareKit
//
//  Created by Zoreslav Khimich on 10/8/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UploadcareError.h"
#import "UploadcareKit.h"
#import "UploadcareStatusWatcher.h"
#import "PTPusher.h"
#import "PTPusherChannel.h"
#import "PTPusherEvent.h"
#import "AFJSONRequestOperation.h"


/* Move this out */
extern NSString *const UploadcareBaseUploadURL;
static NSString *const UploadcarePusherKey = @"79ae88bd931ea68464d9";
/* ^^ */

static const NSTimeInterval UCSWPusherTimeout = 2.;     // if the Pusher is still not working after this amount of time (in seconds), poll will start
static const NSTimeInterval UCSWPollRate = 1. / 4;

@interface UploadcareStatusWatcher ()

@property NSString *token;
@property PTPusher *pusher;
@property NSTimeInterval pusherTimeout;

@property (strong) UploadcareProgressBlock progressBlock;
@property (strong) UploadcareSuccessBlock successBlock;
@property (strong) UploadcareFailureBlock failureBlock;

@end

#pragma mark -

@implementation UploadcareStatusWatcher

- (id)initWithToken: (NSString *)token progressBlock:(UploadcareProgressBlock)progressBlock successBlock:(UploadcareSuccessBlock)successBlock failureBlock:(UploadcareFailureBlock)failureBlock {
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
        [self schedulePollIfPusherFails];
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

- (void)schedulePollIfPusherFails {
    [self performSelector:@selector(poll) withObject:nil afterDelay:_pusherTimeout]; /* TODO: sort out run loops */
}

- (void)poll {
    NSURLRequest *statusRequest = [NSURLRequest requestWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@/status/?token=%@", UploadcareBaseUploadURL, self.token]]];
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
        NSError *wrappedError = [NSError errorWithDomain: UploadcareErrorDomain
                                                    code: UploadcareErrorPollingStatus
                                                userInfo:  @{
                               NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to retrieve the status of the upload", nil),
                                    NSUnderlyingErrorKey: error
                                 }];
        [self didReceiveUploadError: wrappedError];
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
        [self schedulePollIfPusherFails];
    } else if ([statusName isEqualToString:@"success"]) {
        /* success */
        [self didReceiveUploadSuccessWithDetails:data];
    } else if ([statusName isEqualToString:@"error"] || [statusName isEqualToString:@"fail"]) {
        /* error */
        NSError *wrappedError = [NSError errorWithDomain: UploadcareErrorDomain
                                                    code: UploadcareErrorUploadingFromURL
                                                userInfo: @{
                               NSLocalizedDescriptionKey: NSLocalizedString(@"Uploadcare failed to upload file from the Internet", nil),
                        NSLocalizedFailureReasonErrorKey: NSLocalizedString(data[@"error"], nil)
                                 }];
        [self didReceiveUploadError: wrappedError];
    } else {
        /* unknown status */
        [self schedulePollIfPusherFails];
    }
}

- (void)didReceiveProgressInBytes:(long long)uploadedBytes ofTotal:(long long)totalBytes {
    self.progressBlock(uploadedBytes, totalBytes);
}

- (void)didReceiveUploadSuccessWithDetails:(id)data {
    NSString *fileId = data[@"file_id"];
    self.successBlock(fileId);
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

+ (id)watchUploadWithToken:(NSString *)token progressBlock:(UploadcareProgressBlock)progressBlock successBlock:(UploadcareSuccessBlock)successBlock failureBlock:(UploadcareFailureBlock)failureBlock{
    UploadcareStatusWatcher *watcher = [[UploadcareStatusWatcher alloc]initWithToken:token progressBlock:progressBlock successBlock:successBlock failureBlock:failureBlock];
    [[self watchers] setObject:watcher forKey:token];
    return watcher;
}

+ (PTPusher *)sharedPusher {
    static PTPusher *_pusher = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _pusher = [PTPusher pusherWithKey:UploadcarePusherKey connectAutomatically:YES encrypted:YES];
        // TODO: delegate
    });
    return _pusher;
}

+ (void)preheatPusher {
    [self sharedPusher];
}

@end
