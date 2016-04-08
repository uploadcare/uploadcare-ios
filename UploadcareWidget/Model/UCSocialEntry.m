//
//  UCSocialEntry.m
//  ExampleProject
//
//  Created by Yury Nechaev on 07.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCSocialEntry.h"

@implementation UCSocialEntry

+ (NSDictionary *)mapping {
    return @{@"action":@"action",
             @"mimeType":@"mimetype",
             @"thumbnail":@"thumbnail",
             @"title":@"title"};
}

+ (NSDictionary *)collectionMapping {
    return @{@"action":[UCSocialEntryAction class]};
}

@end
