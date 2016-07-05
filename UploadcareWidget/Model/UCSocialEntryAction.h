//
//  UCSocialEntryAction.h
//  ExampleProject
//
//  Created by Yury Nechaev on 07.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCSocialObject.h"
#import "UCSocialPath.h"

typedef NS_ENUM(NSUInteger, UCSocialEntryActionType) {
    UCSocialEntryActionTypeUnknown,
    UCSocialEntryActionTypeSelectFile,
    UCSocialEntryActionTypeOpenPath
};

@interface UCSocialEntryAction : UCSocialObject

@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) UCSocialPath *path;

- (UCSocialEntryActionType)actionType;

@end
