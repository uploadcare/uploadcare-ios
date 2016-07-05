//
//  UCGroupPostRequest.h
//  Cloudkit test
//
//  Created by Yury Nechaev on 04.04.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCAPIRequest.h"

/**
 *  Creates group with the provided file uuids.
 *  @see https://uploadcare.com/documentation/upload/#create-group
 */
@interface UCGroupPostRequest : UCAPIRequest

+ (instancetype)requestWithFileIDs:(NSArray<NSString *> *)fileIDs;

@end
