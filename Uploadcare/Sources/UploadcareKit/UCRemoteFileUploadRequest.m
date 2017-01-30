//
//  UCRemoteFileUploadRequest.m
//  Cloudkit test
//
//  Created by Yury Nechaev on 01.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCRemoteFileUploadRequest.h"
#import "UCConstantsHeader.h"
#import "NSDictionary+UrlEncoding.h"
#import "NSString+EncodeRFC3986.h"

@interface UCRemoteFileUploadRequest ()
@property (nonatomic, strong) NSString *fileURL;

@end

@implementation UCRemoteFileUploadRequest

+ (instancetype)requestWithRemoteFileURL:(NSString *)fileURL {
    return [[UCRemoteFileUploadRequest alloc] initWithRemoteFileURL:fileURL];
}

// We need to override this method because setQuery: method of NSURLComponents corrupts embed link parameter
- (NSMutableURLRequest *)request {
    NSURLComponents *components = [NSURLComponents new];
    [components setScheme:UCAPIProtocol];
    [components setHost:UCApiRoot];
    [components setPath:self.path];
    [components setQuery:self.parameters.uc_urlOriginalString];
    NSString *requestString = [components string];
    NSString *finalRequestString = [requestString stringByAppendingFormat:@"&source_url=%@", self.fileURL.encodedRFC3986];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:finalRequestString]];
    return request;
}

- (id)initWithRemoteFileURL:(NSString *)fileURL {
    NSParameterAssert(fileURL);
    self = [super init];
    if (self) {
        self.path = UCRemoteFileUploadingPath;
        self.fileURL = fileURL;
        self.parameters = @{};
    }
    return self;
}

@end
