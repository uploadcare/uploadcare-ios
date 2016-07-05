//
//  UCSocialEntry.m
//  ExampleProject
//
//  Created by Yury Nechaev on 07.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCSocialEntry.h"
#import "UCSocialConstantsHeader.h"

@implementation UCSocialEntry

+ (NSDictionary *)mapping {
    return @{@"action":@"action",
             @"mimeType":@"mimetype",
             @"thumbnail":@"thumbnail",
             @"title":@"title"};
}

+ (NSDictionary *)collectionMapping {
    return @{@"action":[UCSocialEntryAction class]};
}

- (NSURL *)thumbnailUrl {
    return UCAbsoluteURL(self.thumbnail);
}

NSURL *UCAbsoluteURL(NSString *address) {
    NSURL *resultURL = [NSURL URLWithString:address];
    if (!resultURL.host) {
        NSURLComponents *components = [[NSURLComponents alloc] init];
        [components setScheme:UCSocialProtocol];
        [components setHost:UCSocialAPIRoot];
        NSURL *baseURL = [components URL];
        resultURL = [NSURL URLWithString:address relativeToURL:baseURL];
    }
    return resultURL;
}

@end
