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
        return UCGalleryModeGrid;
    } else if ([self.viewType isEqualToString:@"table"]) {
        return UCGalleryModeList;
    } else if ([self.viewType isEqualToString:@"stacks"]) {
        return UCGalleryModeAlbumsGrid;
    } else if ([self.viewType isEqualToString:@"tiles"]) {
        return UCGalleryModePersonList;
    }
    
    return UCGalleryModeGrid;
}

@end
