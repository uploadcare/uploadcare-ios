//
//  UCSocialEntriesRequest.m
//  ExampleProject
//
//  Created by Yury Nechaev on 06.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCSocialEntriesRequest.h"
#import "UCSocialSource.h"
#import "UCSocialChunk.h"

@interface UCSocialEntriesRequest ()
@property (nonatomic, strong) UCSocialSource *source;
@property (nonatomic, strong) UCSocialChunk *chunk;
@end

@implementation UCSocialEntriesRequest

+ (instancetype)requestWithSource:(UCSocialSource *)source chunk:(UCSocialChunk *)chunk {
    UCSocialEntriesRequest *req = [[UCSocialEntriesRequest alloc] initWithSource:source chunk:chunk];
    return req;
}

- (id)initWithSource:(UCSocialSource *)source chunk:(UCSocialChunk *)chunk {
    self = [super init];
    if (self) {
        self.source = source;
        self.chunk = chunk;
        self.path = [source.urls.sourceBase stringByAppendingString:chunk.path];
    }
    return self;
}

@end
