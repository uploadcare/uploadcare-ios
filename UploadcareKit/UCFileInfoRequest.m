//
//  UCFileInfoRequest.m
//  Cloudkit test
//
//  Created by Yury Nechaev on 04.04.16.
//  Copyright © 2016 Riders. All rights reserved.
//

#import "UCFileInfoRequest.h"
#import "UCConstantsHeader.h"


@implementation UCFileInfoRequest

+ (instancetype)requestWithFileID:(NSString *)fileID {
    UCFileInfoRequest *request = [[UCFileInfoRequest alloc] initWithfileID:fileID];
    return request;
}

- (id)initWithfileID:(NSString *)fileID {
    self = [super init];
    if (self) {
        self.parameters = @{@"file_id": fileID};
        self.path = UCFileInfoPath;
    }
    return self;
}

@end
