//
//  UCSocialPath.h
//  ExampleProject
//
//  Created by Yury Nechaev on 08.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCSocialObject.h"
#import "UCSocialChunk.h"

@interface UCSocialPath : UCSocialObject

@property (nonatomic, strong) NSArray<UCSocialChunk*> *chunks;

@end
