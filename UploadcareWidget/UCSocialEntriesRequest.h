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
@class UCSocialEntriesCollection;

@interface UCSocialEntriesRequest : UCSocialRequest

+ (instancetype)requestWithSource:(UCSocialSource *)source
                            chunk:(UCSocialChunk *)chunk;

+ (instancetype)nextPageRequestWithSource:(UCSocialSource *)source
                                  entries:(UCSocialEntriesCollection *)collection
                                    chunk:(UCSocialChunk *)chunk;
@end
