//
//  UCRecentUploads.m
//  WidgetExample
//
//  Created by Zoreslav Khimich on 11/18/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UCRecentUploads.h"

NSString *const UCRecentUploadsDefaultsKey = @"UCRecentUploadsDefaultsKey";
NSString *const UCRecentUploadsURLKey = @"UCRecentUploadsURLKey";
NSString *const UCRecentUploadsThumbnailURLKey = @"UCRecentUploadsThumbnailURLKey";
NSString *const UCRecentUploadsDateKey = @"UCRecentUploadsDateKey";
NSString *const UCRecentUploadsSourceTypeKey = @"UCRecentUploadsSourceTypeKey";
NSString *const UCRecentUploadsErrorKey = @"UCRecentUploadsErrorKey";
NSString *const UCRecentUploadsTitleKey = @"UCRecentUploadsTitleKey";

NSString *const UCRecentUploadsNoError = @"UCRecentUploadsNoError";
NSString *const UCRecentUploadsSystemError = @"UCRecentUploadsSystemError";
/* The plan is to have one more kind of error, an URL/user/upload error which indicates
   that the upload itself is at fault (e.g. broken URL, invalid response, etc) */


@interface UCRecentUploads ()
+ (void)updateSortedUploads;
@end

static __strong NSArray *_sortedUploads;

@implementation UCRecentUploads

+ (void)recordUploadWithInfo:(NSDictionary *)uploadInfo {
    NSMutableDictionary *mutableUploadInfo = [uploadInfo mutableCopy];
    mutableUploadInfo[UCRecentUploadsDateKey] = [NSDate date];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *uploads = [defaults objectForKey:UCRecentUploadsDefaultsKey];
    NSMutableDictionary *mutableUploads = uploads ? [uploads mutableCopy] : [NSMutableDictionary dictionary];
    NSURL *sourceURL = uploadInfo[UCRecentUploadsURLKey];
    mutableUploads[sourceURL] = (NSDictionary *)mutableUploadInfo;
    [defaults setObject:mutableUploads forKey:UCRecentUploadsDefaultsKey];
    [defaults synchronize];
    [self updateSortedUploads];
}

+ (void)updateSortedUploads {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *uploads = [defaults objectForKey:UCRecentUploadsDefaultsKey];
    if (!uploads) {
        _sortedUploads = [NSArray array];
        return;
    };
    _sortedUploads = [[uploads allValues]sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate *const date1 = obj1[UCRecentUploadsDateKey];
        NSDate *const date2 = obj2[UCRecentUploadsDateKey];
        return [date2 compare:date1];
    }];
}

+ (NSArray *)sortedUploads {
    if (!_sortedUploads) [self updateSortedUploads];
    return _sortedUploads;
}

+ (void)deleteRecordWithSortedIndex:(NSInteger)idx {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *uploads = [defaults objectForKey:UCRecentUploadsDefaultsKey];
    if (!uploads) return;
    NSMutableDictionary *mutableUploads = [uploads mutableCopy];
    [mutableUploads removeObjectForKey:[[self.sortedUploads objectAtIndex:idx] objectForKey:UCRecentUploadsURLKey]];
    [defaults setObject:mutableUploads forKey:UCRecentUploadsDefaultsKey];
    [defaults synchronize];
    [self updateSortedUploads];
}

@end
