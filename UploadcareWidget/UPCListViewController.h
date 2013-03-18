//
//  UPCListViewController.h
//  Social Source
//
//  Created by Zoreslav Khimich on 09/03/2013.
//  Copyright (c) 2013 zrxq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UPCThingsViewController.h"

@class UPCSocialSourceClient;

@interface UPCListViewController : UITableViewController<UPCThingsViewController>

- (id)init;

@property (strong, nonatomic) NSArray *things;
@property (strong, nonatomic) NSString *stylePath;

@end
