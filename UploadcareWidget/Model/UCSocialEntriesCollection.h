//
//  UCSocialEntriesCollection.h
//  ExampleProject
//
//  Created by Yury Nechaev on 07.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCSocialObject.h"

@class UCSocialEntry;

@interface UCSocialEntriesCollection : UCSocialObject

@property (nonatomic, strong) NSDictionary *nextPage;
@property (nonatomic, strong) NSDictionary *path;
@property (nonatomic, strong) NSDictionary *root;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) NSArray<UCSocialEntry*> *entries;

@end
