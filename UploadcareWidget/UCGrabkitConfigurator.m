//
//  UCGrabkitConfigurator.m
//  WidgetExample
//
//  Created by Zoreslav Khimich on 11/12/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UCGrabkitConfigurator.h"

@implementation UCGrabkitConfigurator

#pragma mark - picasa: not implemented

- (NSString *)picasaClientId {
    [NSException raise:@"Not Implemented" format:@"Picasa doesn't work at the moment"];
    return nil; /* not implemented */
}

- (NSString *)picasaClientSecret {
    return [self picasaClientId]; /* not implemented */
}

#pragma mark - shared instance

+ (id)shared {
    static UCGrabkitConfigurator *_shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[UCGrabkitConfigurator alloc]init];
    });
    return _shared;
}

#pragma mark

- (NSString *)facebookTaggedPhotosAlbumName {
    return NSLocalizedString(@"Photos of You", @"The name of the album 'Tagged photos' on Facebook");
}

@end
