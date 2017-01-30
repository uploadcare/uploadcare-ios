//
//  UCGroupInfoRequest.m
//  Cloudkit test
//
//  Created by Yury Nechaev on 04.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCGroupInfoRequest.h"
#import "UCConstantsHeader.h"

@implementation UCGroupInfoRequest

+ (instancetype)requestWithGroupID:(NSString *)groupID {
    UCGroupInfoRequest *req = [[UCGroupInfoRequest alloc] initWithGroupID:groupID];
    return req;
}

- (id)initWithGroupID:(NSString *)groupID {
    NSParameterAssert(groupID);
    self = [super init];
    if (self) {
        self.path = UCGroupInfoPath;
        self.parameters = @{@"group_id": groupID};
    }
    return self;
}

@end
