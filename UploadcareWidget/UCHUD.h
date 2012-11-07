//
//  UCHUD.h
//  WidgetExample
//
//  Created by Zoreslav Khimich on 11/7/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCHUD : NSObject

+ (void)show;
+ (void)dismiss;
+ (void)setProgress:(CGFloat)progress;
+ (void)setText:(NSString *)text;

@end
