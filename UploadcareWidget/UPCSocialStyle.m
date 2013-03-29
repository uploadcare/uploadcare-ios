//
//  UPCSocialStyle.m
//  Social Source
//
//  Created by Zoreslav Khimich on 10/03/2013.
//  Copyright (c) 2013 zrxq. All rights reserved.
//

#import "UPCSocialStyle.h"

@implementation UPCSocialStyle

+ (UPCPresentationType)presentationTypeForPath:(NSString *)stylePath {
    NSArray *chunks = [stylePath pathComponents];
    NSString *source = chunks[0];
    NSString *root_chunk = chunks[1];
    
    /* Instagram */
    if ([source isEqualToString:@"instagram"]) {
        if ([stylePath isEqualToString:@"instagram/follows"]) {
            return UPCPresentationTypeList;
        }
        return UPCPresentationTypeGrid;
    }
    
    /* Facebook */
    if ([source isEqualToString:@"facebook"]) {
        if ([stylePath isEqualToString:@"facebook/me"]) return UPCPresentationTypeList;
        if ([root_chunk isEqualToString:@"friends"] && chunks.count < 4) return UPCPresentationTypeList;
        return UPCPresentationTypeGrid;
    }
    
    /* Dropbox */
    if ([source isEqualToString:@"dropbox"]) {
        return UPCPresentationTypeList;
    }
    
    /* Google Drive */
    if ([source isEqualToString:@"gdrive"]) {
        return UPCPresentationTypeList;
    }
    
    return UPCPresentationTypeUnknown;
}

+ (UPCListStyle)listStyleForPath:(NSString *)stylePath {
    NSString *firstComponent = [stylePath pathComponents][0];
    if ([firstComponent isEqualToString:@"gdrive"]) {
        return UPCListStyle16x16;
    } else if ([firstComponent isEqualToString:@"dropbox"]) {
        if (stylePath.pathComponents.count >= 3 && [stylePath.pathComponents[2]isEqualToString:@"Camera%20Uploads"]) {
            return UPCListStyle80x80;
        }
        return UPCListStyle24x24;
    } else if ([stylePath isEqualToString:@"facebook/friends"]) {
        return UPCListStyle48x48;
    } else
    return UPCListStyle80x80;
}

@end
