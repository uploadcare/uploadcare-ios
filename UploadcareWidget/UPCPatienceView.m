//
//  UPCPatienceView.m
//  Social Source
//
//  Created by Zoreslav Khimich on 01/03/2013.
//  Copyright (c) 2013 zrxq. All rights reserved.
//

#import "UPCPatienceView.h"

#import <QuartzCore/QuartzCore.h>

@interface UPCPatienceView ()

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UILabel *loadingLabel;

@end

@implementation UPCPatienceView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1.];
        
        /* Label */
        _loadingLabel = [[UILabel alloc]init];
        _loadingLabel.text = NSLocalizedString(@"Loading...", @"Activity indicator label (\"Loading...\")");
        _loadingLabel.backgroundColor = [UIColor clearColor];
        _loadingLabel.textColor = [UIColor colorWithWhite:.33f alpha:1.f];
        _loadingLabel.shadowColor = [UIColor whiteColor];
        _loadingLabel.shadowOffset = CGSizeMake(0, 1);
        _loadingLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]*0.9];
        [_loadingLabel sizeToFit];
        [self addSubview:_loadingLabel];
        
        /* Spinner */
        _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_activityIndicator];
        
        [self.activityIndicator startAnimating];
        
        /* Autoresizing mask */
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    BOOL isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    
    CGFloat loadingWidth = CGRectGetWidth(_activityIndicator.bounds)+5.f+CGRectGetWidth(_loadingLabel.bounds);
    CGFloat loadingHeight = CGRectGetHeight(_activityIndicator.bounds);
    CGFloat statusBarOffset = isPortrait ? CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) : CGRectGetWidth([UIApplication sharedApplication].statusBarFrame);

    CGPoint viewCenter = [self convertPoint:CGPointMake(CGRectGetWidth(self.window.bounds) * 0.5, CGRectGetHeight(self.window.bounds) * 0.5) fromView:nil];
    viewCenter.y += statusBarOffset;
    
    _activityIndicator.center = CGPointMake(viewCenter.x - loadingWidth * .5f + CGRectGetWidth(_activityIndicator.bounds) * .5f, viewCenter.y - loadingHeight * .5f);
    
    _loadingLabel.center = CGPointMake(_activityIndicator.center.x+CGRectGetWidth(_activityIndicator.bounds) * .5f + 5.f + CGRectGetWidth(_loadingLabel.bounds) * .5f, _activityIndicator.center.y);
}

@end
