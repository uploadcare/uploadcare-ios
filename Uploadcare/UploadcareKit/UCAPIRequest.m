//
//  UCAPIRequest.m
//  Riders
//
//  Created by Yury Nechaev on 31.03.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCAPIRequest.h"
#import "UCConstantsHeader.h"
#import "NSDictionary+UrlEncoding.h"

@implementation UCAPIRequest


- (id) init {
    self = [super init];
    if (self) {
        _parameters = @{};
    }
    return self;
}

- (NSMutableURLRequest *)request {
    NSURLComponents *components = [NSURLComponents new];
    [components setScheme:UCAPIProtocol];
    [components setHost:UCApiRoot];
    [components setPath:self.path];
    [components setQuery:self.parameters.uc_urlOriginalString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[components URL]];
    
    return request;
}

@end

@interface UCAPIRequestPayload ()

@end

@implementation UCAPIRequestPayload

+ (instancetype) payloadWithData:(NSData *)payload name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType {
    UCAPIRequestPayload *payloadInstance = [[UCAPIRequestPayload alloc] initWithData:payload name:name fileName:fileName mimeType:mimeType];
    return payloadInstance;
}

- (id) initWithData:(NSData *)payload name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType {
    self = [super init];
    if (self) {
        _payload = payload;
        _name = name;
        _fileName = fileName;
        _mimeType = mimeType;
    }
    return self;
}


@end
