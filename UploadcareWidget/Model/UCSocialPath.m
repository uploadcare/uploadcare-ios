//
//  UCSocialPath.m
//  ExampleProject
//
//  Created by Yury Nechaev on 08.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCSocialPath.h"

@implementation UCSocialPath

+ (NSDictionary *)mapping {
    return @{@"chunks":@"chunks"};
}

+ (NSDictionary *)collectionMapping {
    return @{@"chunks": [UCSocialChunk class]};
}

@end
