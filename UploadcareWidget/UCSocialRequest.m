//
//  UCSocialRequest.m
//  ExampleProject
//
//  Created by Yury Nechaev on 05.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCSocialRequest.h"
#import "UCSocialConstantsHeader.h"
#import "NSDictionary+UrlEncoding.h"

@implementation UCSocialRequest

- (id) init {
    self = [super init];
    if (self) {
        _parameters = @{};
    }
    return self;
}

- (NSMutableURLRequest *)request {
    NSURLComponents *components = [NSURLComponents new];
    [components setScheme:UCSocialProtocol];
    [components setHost:UCSocialAPIRoot];
    [components setPath:self.path];
    [components setQuery:self.parameters.allKeys.count ? self.parameters.uc_urlOriginalString : nil];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[components URL]];
    for (NSString *key in self.headers) {
        [request setValue:self.headers[key] forHTTPHeaderField:key];
    }
    return request;
}

@end
