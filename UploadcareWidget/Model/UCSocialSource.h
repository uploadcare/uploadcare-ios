//
//  UCSocialSource.h
//  ExampleProject
//
//  Created by Yury Nechaev on 06.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UCSocialObject.h"

@interface UCSocialSource : UCSocialObject

@property (nonatomic, strong) NSString *sourceName;
@property (nonatomic, strong) NSArray *rootChunks;
@property (nonatomic, strong) NSDictionary *urls;

@end
