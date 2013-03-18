//
//  UPCGradientView.m
//  Social Source
//
//  Created by Zoreslav Khimich on 06/03/2013.
//  Copyright (c) 2013 zrxq. All rights reserved.
//

#import "UPCGradientView.h"

@implementation UPCGradientView

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (CAGradientLayer*)gradientLayer {
    return (CAGradientLayer *)self.layer;
}

@end
