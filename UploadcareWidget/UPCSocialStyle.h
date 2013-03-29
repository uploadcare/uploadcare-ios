//
//  UPCSocialStyle.h
//  Social Source
//
//  Created by Zoreslav Khimich on 10/03/2013.
//  Copyright (c) 2013 zrxq. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    UPCPresentationTypeUnknown = 0,
    UPCPresentationTypeGrid = 1,
    UPCPresentationTypeList,
} UPCPresentationType;

typedef enum {
    UPCListStyle16x16 = 1,
    UPCListStyle24x24,
    UPCListStyle48x48,
    UPCListStyle80x80,
} UPCListStyle;

@interface UPCSocialStyle : NSObject

+ (UPCPresentationType)presentationTypeForPath:(NSString *)stylePath;
+ (UPCListStyle)listStyleForPath:(NSString *)stylePath;

@end
