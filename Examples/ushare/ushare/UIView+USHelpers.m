//
//  UIView+USHelpers.m
//  uShare
//
//  Created by Zoreslav Khimich on 12/25/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UIView+USHelpers.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (USHelpers)

- (void)slideInUsing:(NSString*)transitionSubtype {
    [CATransaction begin];
    CATransition *moveIn = [[CATransition alloc]init];
    moveIn.duration = .25;
    moveIn.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    moveIn.type = kCATransitionMoveIn;
    moveIn.subtype = transitionSubtype;
    [self.layer addAnimation:moveIn forKey:kCATransition];
    self.hidden = NO;
    [CATransaction commit];
}

- (void)slideOutUsing:(NSString*)transitionSubtype {
    [CATransaction begin];
    CATransition *moveOut = [[CATransition alloc]init];
    moveOut.duration = .25;
    moveOut.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    moveOut.type = kCATransitionReveal;
    moveOut.subtype = transitionSubtype;
    [self.layer addAnimation:moveOut forKey:kCATransition];
    self.hidden = YES;
    [CATransaction commit];
}

@end
