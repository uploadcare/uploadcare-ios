//
//  NSString+EncodeRFC3986.m
//  ExampleProject
//
//  Created by Yury Nechaev on 13.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "NSString+EncodeRFC3986.h"

@implementation NSString (EncodeRFC3986)

- (NSString *)encodedRFC3986 {
    NSString *unreservedChars = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~";
    NSCharacterSet *unreservedCharset = [NSCharacterSet characterSetWithCharactersInString:unreservedChars];
    NSString *encodedString = [self stringByAddingPercentEncodingWithAllowedCharacters:unreservedCharset];
    return encodedString ?: self;
}

@end
