//
//  UCSocialObject.h
//  ExampleProject
//
//  Created by Yury Nechaev on 06.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UCSocialMappingProtocol <NSObject>

@required
+ (NSDictionary *)mapping;
+ (NSDictionary *)collectionMapping;

@end

@interface UCSocialObject : NSObject <UCSocialMappingProtocol>

- (id)initWithSerializedObject:(id)object;

@end
