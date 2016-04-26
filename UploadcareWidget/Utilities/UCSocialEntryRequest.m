//
//  UCSocialEntryRequest.m
//  ExampleProject
//
//  Created by Yury Nechaev on 11.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCSocialEntryRequest.h"
#import "UCSocialSource.h"
#import "UCSocialConstantsHeader.h"

@interface UCSocialEntryRequest ()
@property (nonatomic, strong) UCSocialSource *source;
@property (nonatomic, strong) NSString *file;
@end

@implementation UCSocialEntryRequest

+ (instancetype)requestWithSource:(UCSocialSource *)source file:(NSString *)file {
    UCSocialEntryRequest *request = [[UCSocialEntryRequest alloc] initWithSocialSource:source file:file];
    return request;
}

- (id)initWithSocialSource:(UCSocialSource *)source file:(NSString *)file {
    self = [super init];
    if (self) {
        _source = source;
        _file = file;
        self.path = source.urls.done;
    }
    return self;
}

- (NSMutableURLRequest *)request {
    NSMutableURLRequest *request = [super request];
    [request setHTTPBody:[[NSString stringWithFormat:@"file=%@", self.file] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    return request;
}

@end
