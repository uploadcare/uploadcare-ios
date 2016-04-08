//
//  UCSocialEntriesCollection.m
//  ExampleProject
//
//  Created by Yury Nechaev on 07.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCSocialEntriesCollection.h"
#import "UCSocialEntry.h"

@implementation UCSocialEntriesCollection

- (NSString *)nextPagePath {
    if (!self.nextPage) return nil;
    NSArray *chunks = self.nextPage[@"chunks"];
    id chunk = chunks.firstObject;
    return chunk[@"path_chunk"];
}

+ (NSDictionary *)mapping {
    return @{@"nextPage":@"next_page",
             @"path":@"path",
             @"root":@"root",
             @"userInfo":@"userinfo",
             @"entries":@"things"};
}

+ (NSDictionary *)collectionMapping {
    return @{@"entries": [UCSocialEntry class]};
}

@end
