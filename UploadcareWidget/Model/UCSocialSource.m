//
//  UCSocialSource.m
//  ExampleProject
//
//  Created by Yury Nechaev on 06.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCSocialSource.h"
#import "UCSocialMacroses.h"
#import "UCSocialChunk.h"

@implementation UCSocialSource

+ (NSDictionary *)mapping {
    
    return @{@"sourceName":@"name",
             @"rootChunks":@"root_chunks",
             @"urls":@"urls"};
}

+ (NSDictionary *)collectionMapping {
    return @{@"rootChunks":[UCSocialChunk class]};
}

@end
