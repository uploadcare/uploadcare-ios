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

@implementation UCSocialEntriesCollection

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
