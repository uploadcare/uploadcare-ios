//
//  UploadCareFile.m
//  UploadCareKit
//
//  Created by Artyom Loenko on 6/1/12.
//  Copyright (c) 2012 artyom.loenko@mac.com. All rights reserved.
//

#import "UploadcareFile.h"

@implementation UploadcareFile

@synthesize info;

- (id)init
{
    self = [super init];
    if (self) {}
    return self;
}

- (NSString *)apiURI {
    return [NSString stringWithFormat:@"/files/%@/", [self file_id]];
}

- (NSString *)file_id {
    if ([[[self info] objectForKey:@"file_id"] isKindOfClass:[NSNull class]]
        || [[[self info] objectForKey:@"file_id"] isEqualToString:@"null"]) {
        return nil;
    }
    
    return [[self info] objectForKey:@"file_id"];
}

- (NSDate *)last_keep_claim {
    if ([[[self info] objectForKey:@"last_keep_claim"] isKindOfClass:[NSNull class]]
        || [[[self info] objectForKey:@"last_keep_claim"] isEqualToString:@"null"]) {
        return nil;
    }
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    return [dateFormatter dateFromString:[[self info] objectForKey:@"last_keep_claim"]];
}

- (BOOL)made_public {
    if ([[[self info] objectForKey:@"made_public"] isKindOfClass:[NSNull class]]) {
        return NO;
    }
    
    return [[[self info] objectForKey:@"made_public"] boolValue];
}

- (NSString *)mime_type {
    if ([[[self info] objectForKey:@"mime_type"] isKindOfClass:[NSNull class]]
        || [[[self info] objectForKey:@"mime_type"] isEqualToString:@"null"]) {
        return nil;
    }
    
    return [[self info] objectForKey:@"mime_type"];
}

- (BOOL)on_s3 {
    if ([[[self info] objectForKey:@"on_s3"] isKindOfClass:[NSNull class]]) {
        return NO;
    }
    
    return [[[self info] objectForKey:@"on_s3"] boolValue];
}

- (NSURL *)original_file_url {
    if ([[[self info] objectForKey:@"original_file_url"] isKindOfClass:[NSNull class]]
        || [[[self info] objectForKey:@"original_file_url"] isEqualToString:@"null"]) {
        return nil;
    }
    
    return [NSURL URLWithString:[[self info] objectForKey:@"original_file_url"]];
}

- (NSString *)original_filename {
    if ([[[self info] objectForKey:@"original_filename"] isKindOfClass:[NSNull class]]
        || [[[self info] objectForKey:@"original_filename"] isEqualToString:@"null"]) {
        return nil;
    }
    
    return [[self info] objectForKey:@"original_filename"];
}

- (NSString *)removed {
    if ([[[self info] objectForKey:@"removed"] isKindOfClass:[NSNull class]]
        || [[[self info] objectForKey:@"removed"] isEqualToString:@"null"]) {
        return nil;
    }
    
    return [[self info] objectForKey:@"removed"];
}

- (int)size {
    if ([[[self info] objectForKey:@"size"] isKindOfClass:[NSNull class]]) {
        return 0;
    }
    
    return [[[self info] objectForKey:@"size"] intValue];
}

- (NSDate *)upload_date {
    if ([[[self info] objectForKey:@"upload_date"] isKindOfClass:[NSNull class]]
        || [[[self info] objectForKey:@"upload_date"] isEqualToString:@"null"]) {
        return nil;
    }
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    return [dateFormatter dateFromString:[[self info] objectForKey:@"upload_date"]];
}

- (NSURL *)url {
    if ([[[self info] objectForKey:@"url"] isKindOfClass:[NSNull class]]
        || [[[self info] objectForKey:@"url"] isEqualToString:@"null"]) {
        return nil;
    }
    
    return [NSURL URLWithString:[[self info] objectForKey:@"url"]];
}

@end
