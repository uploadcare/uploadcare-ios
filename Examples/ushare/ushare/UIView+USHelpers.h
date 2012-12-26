//
//  UIView+USHelpers.h
//  uShare
//
//  Created by Zoreslav Khimich on 12/25/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (USHelpers)
- (void)moveInFrom:(NSString*)transitionSubtype;
- (void)moveOutFrom:(NSString*)transitionSubtype;
@end
