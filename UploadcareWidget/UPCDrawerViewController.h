//
//  UPCDraweViewController.h
//  Social Source
//
//  Created by Zoreslav Khimich on 03/03/2013.
//  Copyright (c) 2013 zrxq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPCDrawerViewController : UITableViewController

- (id)initWithChunks:(NSArray *)chunks serviceName:(NSString *)serviceName;
- (CGFloat) heightNeeded;

@end
