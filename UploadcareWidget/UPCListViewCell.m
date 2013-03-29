//
//  UPCListViewCell.m
//  Social Source
//
//  Created by Zoreslav Khimich on 10/03/2013.
//  Copyright (c) 2013 zrxq. All rights reserved.
//

#import "UPCListViewCell.h"

#import <QuartzCore/QuartzCore.h>

NSString *const UPCListCell16x16 = @"UPCListCell16x16";
NSString *const UPCListCell24x24 = @"UPCListCell24x24";
NSString *const UPCListCell48x48 = @"UPCListCell48x48";
NSString *const UPCListCell80x80 = @"UPCListCell80x80";

@implementation UPCListViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        /* thumbnail view */
        _thumnailView = [[UIImageView alloc]init];
        _thumnailView.clipsToBounds = YES;
        [self.contentView addSubview:_thumnailView];
        
        /* title label */
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.contentMode = UIViewContentModeLeft;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _titleLabel.shadowColor = [UIColor whiteColor];
        _titleLabel.shadowOffset = CGSizeMake(0, 1);
        [self.contentView addSubview:_titleLabel];
        
        /* selection */
        UIView *coloredView = [[UIView alloc]init];
        coloredView.backgroundColor = [UIColor colorWithWhite:0.83 alpha:1.];
        [self setSelectedBackgroundView:coloredView];
        
        if (self.reuseIdentifier == UPCListCell16x16) {
            /* 16x16 */
            _thumnailView.contentMode = UIViewContentModeBottomLeft;
            _titleLabel.font = [UIFont systemFontOfSize:16];
        }else if (self.reuseIdentifier == UPCListCell80x80 || self.reuseIdentifier == UPCListCell48x48) {
            /* 60x60  and 48x48 */
            _thumnailView.contentMode = UIViewContentModeScaleAspectFill;
            _thumnailView.layer.cornerRadius = 4.f;
            _titleLabel.font = [UIFont systemFontOfSize:18];
            _titleLabel.numberOfLines = 2;
        }else if (self.reuseIdentifier == UPCListCell24x24) {
            /* 24x24 */
            _thumnailView.contentMode = UIViewContentModeScaleAspectFit;
            _titleLabel.font = [UIFont systemFontOfSize:16];
        }

    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat viewWidth = CGRectGetWidth(self.contentView.bounds);
    CGFloat viewHeight = CGRectGetHeight(self.contentView.bounds);
    
    CGFloat thumbWidth = 0;
    CGFloat thumbHeight = 0;
    
    if (self.reuseIdentifier == UPCListCell16x16) {
        thumbWidth = thumbHeight = 16;
    } else if (self.reuseIdentifier == UPCListCell24x24) {
        thumbWidth = thumbHeight = 24;
    } else if (self.reuseIdentifier == UPCListCell48x48) {
        thumbWidth = thumbHeight = 48;
    } else if (self.reuseIdentifier == UPCListCell80x80) {
        thumbHeight = thumbWidth = 80;
    }
    
    _thumnailView.frame = CGRectMake((int)(viewHeight/2 - thumbHeight/2), (int)(viewHeight/2 - thumbHeight/2), thumbWidth, thumbHeight);
    _titleLabel.frame = CGRectMake(CGRectGetMaxX(_thumnailView.frame)+10, 5, viewWidth-(CGRectGetMaxX(_thumnailView.frame)+10+5), viewHeight-5-5);
}

@end
