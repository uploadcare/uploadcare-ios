//
//  UCGrabkitConfigurator.h
//  WidgetExample
//
//  Created by Zoreslav Khimich on 11/12/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GRKConfiguratorProtocol.h>

@interface UCGrabkitConfigurator : NSObject<GRKConfiguratorProtocol>

+ (id)shared;

@property BOOL facebookIsEnabled;
@property BOOL instagramIsEnabled;

@property BOOL flickrIsEnabled;
@property (strong) NSString *flickrApiKey;
@property (strong) NSString *flickrApiSecret;
@property (strong) NSString *flickrRedirectUri;

@end
