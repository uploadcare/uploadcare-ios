//
//  UPCListViewBusyCell.h
//  Social Source
//
//  Created by Zoreslav Khimich on 17/03/2013.
//  Copyright (c) 2013 zrxq. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const UPCListViewBusyCellIdentifier;

@interface UPCListViewBusyCell : UITableViewCell

@property (readonly, strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end
