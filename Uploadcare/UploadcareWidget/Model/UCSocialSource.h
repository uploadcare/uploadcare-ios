//
//  UCSocialSource.h
//  ExampleProject
//
//  Created by Yury Nechaev on 06.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UCSocialObject.h"
#import "UCSocialChunk.h"

@interface UCSocialSourceURLs : UCSocialObject

@property (nonatomic, strong) NSString *done;
@property (nonatomic, strong) NSString *session;
@property (nonatomic, strong) NSString *sourceBase;

@end

@interface UCSocialSource : UCSocialObject

@property (nonatomic, strong) NSString *sourceName;
@property (nonatomic, strong) NSArray <UCSocialChunk *> *rootChunks;
@property (nonatomic, strong) UCSocialSourceURLs *urls;

@end
