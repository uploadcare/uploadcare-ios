//
//  UPCListViewCell.h
//  Social Source
//
//  Created by Zoreslav Khimich on 10/03/2013.
//  Copyright (c) 2013 zrxq. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const UPCListCell16x16;
extern NSString *const UPCListCell24x24;
extern NSString *const UPCListCell48x48;
extern NSString *const UPCListCell80x80;

@interface UPCListViewCell : UITableViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@property (strong, nonatomic) UIImageView *thumnailView;
@property (strong, nonatomic) UILabel *titleLabel;

@end
