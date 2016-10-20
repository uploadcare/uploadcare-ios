//
//  UCSocialEntryRequest.h
//  ExampleProject
//
//  Created by Yury Nechaev on 11.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCSocialRequest.h"

@class UCSocialSource;

@interface UCSocialEntryRequest : UCSocialRequest

+ (instancetype)requestWithSource:(UCSocialSource *)source file:(NSString *)file;

@end
