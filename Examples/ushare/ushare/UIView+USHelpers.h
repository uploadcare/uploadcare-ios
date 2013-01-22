//
//  UIView+USHelpers.h
//  uShare
//
//  Created by Zoreslav Khimich on 12/25/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (USHelpers)
- (void)slideInUsing:(NSString*)transitionSubtype;
- (void)slideOutUsing:(NSString*)transitionSubtype;
@end
