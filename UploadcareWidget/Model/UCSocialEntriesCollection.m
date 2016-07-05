//
//  UCSocialEntriesCollection.m
//  ExampleProject
//
//  Created by Yury Nechaev on 07.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCSocialEntriesCollection.h"
#import "UCSocialEntry.h"
#import "UCSocialChunk.h"

@interface UCSocialEntriesCollection ()
@property (nonatomic, strong) NSString *viewType;
@property (nonatomic, assign) UCGalleryMode galleryMode;
@end

@implementation UCSocialEntriesCollection

+ (NSDictionary *)mapping {
    return @{@"nextPage":@"next_page",
             @"path":@"path",
             @"root":@"root",
             @"userInfo":@"userinfo",
             @"entries":@"things",
             @"viewType":@"view"};
}

+ (NSDictionary *)collectionMapping {
    return @{@"entries": [UCSocialEntry class]};
}

- (UCGalleryMode)galleryMode {
    if ([self.viewType isEqualToString:@"icons"]) {
        _galleryMode = UCGalleryModeGrid;
    } else if ([self.viewType isEqualToString:@"table"]) {
        _galleryMode = UCGalleryModeList;
    } else if ([self.viewType isEqualToString:@"stacks"]) {
        _galleryMode = UCGalleryModeAlbumsGrid;
    } else if ([self.viewType isEqualToString:@"tiles"]) {
        _galleryMode = UCGalleryModePersonList;
    }
    
    return _galleryMode;
}

@end
