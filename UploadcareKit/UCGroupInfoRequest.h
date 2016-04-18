//
//  UCGroupInfoRequest.h
//  Cloudkit test
//
//  Created by Yury Nechaev on 04.04.16.
//  Copyright © 2016 Riders. All rights reserved.
//

#import "UCAPIRequest.h"

/**
 *  Requests group information from Uploadcare service.
 */
@interface UCGroupInfoRequest : UCAPIRequest

+ (instancetype)requestWithGroupID:(NSString *)groupID;

@end
