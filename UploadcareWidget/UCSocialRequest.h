//
//  UCSocialRequest.h
//  ExampleProject
//
//  Created by Yury Nechaev on 05.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCSocialRequest : NSObject
@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, strong) NSDictionary *headers;
@property (nonatomic, strong) NSString *path;

- (NSMutableURLRequest *)request;
@end
