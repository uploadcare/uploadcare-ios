//
//  UCSocialSourcesRequest.m
//  ExampleProject
//
//  Created by Yury Nechaev on 06.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCSocialSourcesRequest.h"
#import "UCSocialConstantsHeader.h"

@implementation UCSocialSourcesRequest

- (id)init {
    self = [super init];
    if (self) {
        self.path = UCSourcesPath;
    }
    return self;
}

@end
