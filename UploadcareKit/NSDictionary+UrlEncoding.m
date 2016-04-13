//
//  NSDictionary+UrlEncoding.m
//  Riders
//
//  Created by Yury Nechaev on 31.03.16.
//  Copyright © 2016 Whitescape. All rights reserved.
//

#import "NSDictionary+UrlEncoding.h"
#import "NSString+EncodeRFC3986.h"

static NSString *toString(id object) {
    return [NSString stringWithFormat: @"%@", object];
}

static NSString *urlEncode(id object) {
    NSString *string = toString(object);
    return string.encodedRFC3986;
}

@implementation NSDictionary (UrlEncoding)

- (NSString *)uc_urlEncodedString {
    return [self urlStringEncoded:YES];
}

- (NSString *)uc_urlOriginalString {
    return [self urlStringEncoded:NO];
}

- (NSString *)urlStringEncoded:(BOOL)encoded {
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in self) {
        id value = [self objectForKey: key];
        NSString *part = [NSString stringWithFormat: @"%@=%@", encoded ? urlEncode(key) : key, encoded ? urlEncode(value) : value];
        [parts addObject: part];
    }
    return [parts componentsJoinedByString: @"&"];
}


@end
