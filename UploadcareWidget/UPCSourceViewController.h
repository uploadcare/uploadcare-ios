//
//  UPCSourceViewController.h
//  Social Source
//
//  Created by Zoreslav Khimich on 01/03/2013.
//  Copyright (c) 2013 zrxq. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UPCSocialSourceClient;

@interface UPCSourceViewController : UIViewController<UITableViewDelegate>

- (id)initWithSocialSourceClient:(UPCSocialSourceClient *)client source:(USSSource *)source activeRootChunkIndex:(NSUInteger)rootChunkIndex path:(USSPath *)path;

- (void)performSocialSourceAction:(USSAction *)action forItemTitled:(NSString *)title withThumbnailURL:(NSURL *)thumbnailURL thumbnailImage:(UIImage *)thumbnailImage;

- (void)refreshThings;
- (void)fetchNextThingsPage;
- (void)search:(NSString *)text;

@end
