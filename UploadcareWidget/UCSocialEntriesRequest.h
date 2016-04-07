//
//  UCSocialEntriesRequest.h
//  ExampleProject
//
//  Created by Yury Nechaev on 06.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCSocialRequest.h"

@class UCSocialSource;
@class UCSocialChunk;

@interface UCSocialEntriesRequest : UCSocialRequest

+ (instancetype)requestWithSource:(UCSocialSource *)source chunk:(UCSocialChunk *)chunk;

@end
