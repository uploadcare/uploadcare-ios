//
//  UCGrabkitConfigurator.m
//  WidgetExample
//
//  Created by Zoreslav Khimich on 11/12/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UCGrabkitConfigurator.h"

@implementation UCGrabkitConfigurator

- (NSString *)picasaClientId {
    return nil; /* not implemented */
}

- (NSString *)picasaClientSecret {
    return nil; /* not implemented */
}

+ (id)shared {
    static UCGrabkitConfigurator *_shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[UCGrabkitConfigurator alloc]init];
    });
    return _shared;
}

- (NSString *)facebookTaggedPhotosAlbumName {
    return NSLocalizedString(@"Photos of You", @"The name of the album 'Tagged photos' on Facebook");
}

@end
