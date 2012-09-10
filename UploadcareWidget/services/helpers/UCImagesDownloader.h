//
//  UploadcareKit.m
//  UploadcareKit
//
//  Created by Artyom Loenko on 8/1/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRKDemoThumbnail.h"

@interface UCImagesDownloader : NSObject {
    NSUInteger numberOfImagesDownloading;
    NSMutableArray *urlsOfImagesToDownload;
    NSMutableArray *connections;
}

+ (UCImagesDownloader *)sharedInstance;
+ (NSCache *)cache;

- (void)downloadImageAtURL:(NSURL *)imageURL forThumbnail:(GRKDemoThumbnail *)thumbnail;
- (void)removeAllURLsOfImagesToDownload;
- (void)cancelAllConnections;

@end
