//
//  UPCListViewBusyCell.m
//  Social Source
//
//  Created by Zoreslav Khimich on 17/03/2013.
//  Copyright (c) 2013 zrxq. All rights reserved.
//

#import "UPCListViewBusyCell.h"

NSString *const UPCListViewBusyCellIdentifier = @"UPCListViewBusyCellIdentifier";

@interface UPCListViewBusyCell ()
@property (readwrite, strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation UPCListViewBusyCell

- (id)init
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UPCListViewBusyCellIdentifier];
    if (self) {
        _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_activityIndicator];
        [_activityIndicator startAnimating];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews {
    self.activityIndicator.center = CGPointMake(CGRectGetWidth(self.bounds) * .5, CGRectGetHeight(self.bounds) * .5);
}

@end
