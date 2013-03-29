//
//  UPCThingsViewController.h
//  Social Source
//
//  Created by Zoreslav Khimich on 10/03/2013.
//  Copyright (c) 2013 zrxq. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UPCSocialSourceClient;

@protocol UPCThingsViewController <NSObject>

@required
- (void)setThings:(NSArray *)things isLastPage:(BOOL)isLastPage;
@property (strong, nonatomic) NSString *stylePath;

@end
