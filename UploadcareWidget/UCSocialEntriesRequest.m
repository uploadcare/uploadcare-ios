//
//  UCSocialEntriesRequest.m
//  ExampleProject
//
//  Created by Yury Nechaev on 06.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCSocialEntriesRequest.h"
#import "UCSocialSource.h"
#import "UCSocialEntriesCollection.h"
#import "UCSocialChunk.h"

@interface UCSocialEntriesRequest ()
@property (nonatomic, strong) UCSocialSource *source;
@property (nonatomic, strong) UCSocialChunk *chunk;
@end

@implementation UCSocialEntriesRequest

+ (instancetype)nextPageRequestWithSource:(UCSocialSource *)source
                                  entries:(UCSocialEntriesCollection *)collection
                                     path:(NSString *)path {
    UCSocialEntriesRequest *req = [[UCSocialEntriesRequest alloc] initNextPageWithSource:source collection:collection path:path];
    return req;

}

+ (instancetype)requestWithSource:(UCSocialSource *)source chunk:(UCSocialChunk *)chunk path:(NSString *)path {
    UCSocialEntriesRequest *req = [[UCSocialEntriesRequest alloc] initWithSource:source chunk:chunk path:path];
    return req;
}

- (id)initWithSource:(UCSocialSource *)source chunk:(UCSocialChunk *)chunk path:(NSString *)path {
    self = [super init];
    if (self) {
        self.source = source;
        self.chunk = chunk;
        self.path = [source.urls.sourceBase stringByAppendingString:chunk.path];
        if (path) self.path = [self.path stringByAppendingPathComponent:path];
    }
    return self;
}

- (id)initNextPageWithSource:(UCSocialSource *)source
                  collection:(UCSocialEntriesCollection *)collection
                        path:(NSString *)path {
    self = [self initWithSource:source chunk:collection.root path:path];
    if (self) {
        self.path = [self.path stringByAppendingPathComponent:collection.nextPagePath];
    }
    return self;
}

@end
