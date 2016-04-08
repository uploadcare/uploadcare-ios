//
//  UCSocialEntryAction.m
//  ExampleProject
//
//  Created by Yury Nechaev on 07.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCSocialEntryAction.h"

@implementation UCSocialEntryAction

+ (NSDictionary *)mapping {
    
    return @{@"action":@"action",
             @"urlString":@"url",
             @"path":@"path"};
}

+ (NSDictionary *)collectionMapping {
    return nil;
}

- (UCSocialEntryActionType)actionType {
    if ([self.action isEqualToString:@"select_file"]) {
        return UCSocialEntryActionTypeSelectFile;
    } else if ([self.action isEqualToString:@"open_path"]) {
        return UCSocialEntryActionTypeOpenPath;
    }
    return UCSocialEntryActionTypeUnknown;
}

@end
