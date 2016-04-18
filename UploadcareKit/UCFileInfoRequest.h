//
//  UCFileInfoRequest.h
//  Cloudkit test
//
//  Created by Yury Nechaev on 04.04.16.
//  Copyright © 2016 Riders. All rights reserved.
//

#import "UCAPIRequest.h"

/**
 *  Requests file information from Uploadcare service.
 */
@interface UCFileInfoRequest : UCAPIRequest

+ (instancetype)requestWithFileID:(NSString *)fileID;

@end
