//
//  UCRecentUploads.h
//  WidgetExample
//
//  Created by Zoreslav Khimich on 11/18/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const UCRecentUploadsURLKey;
extern NSString *const UCRecentUploadsThumbnailURLKey;
extern NSString *const UCRecentUploadsDateKey;
extern NSString *const UCRecentUploadsSourceTypeKey;
extern NSString *const UCRecentUploadsErrorKey;
extern NSString *const UCRecentUploadsTitleKey;

extern NSString *const UCRecentUploadsNoError;
extern NSString *const UCRecentUploadsUserError;
extern NSString *const UCRecentUploadsSystemError;

@interface UCRecentUploads : NSObject

+ (void)recordUploadWithInfo:(NSDictionary *)uploadInfo;
+ (NSArray *)sortedUploads;
+ (void)deleteRecordWithSortedIndex:(NSInteger)idx;

@end
