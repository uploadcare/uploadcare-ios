//
//  UCSocialEntryAction.m
//  ExampleProject
//
//  Created by Yury Nechaev on 07.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCSocialEntryAction.h"

@implementation UCSocialEntryAction

+ (NSDictionary *)mapping {
    
    return @{@"action":@"action",
             @"urlString":@"url"};
}

+ (NSDictionary *)collectionMapping {
    return nil;
}

@end
