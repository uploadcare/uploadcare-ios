//
//  UPCGalleryViewController.h
//  Social Source
//
//  Created by Zoreslav Khimich on 03/03/2013.
//  Copyright (c) 2013 zrxq. All rights reserved.
//

#import "AQGridViewController.h"
#import "UPCThingsViewController.h"

@class UPCSocialSourceClient;

@interface UPCGalleryViewController : AQGridViewController<UPCThingsViewController, UISearchBarDelegate>

@property (strong, nonatomic) NSArray *things;
@property (strong, nonatomic) NSString *stylePath;

@end
