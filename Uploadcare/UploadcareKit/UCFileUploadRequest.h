//
//  UCFileUploadRequest.h
//  Riders
//
//  Created by Yury Nechaev on 31.03.16.
//  Copyright © 2016 Uploadcare. All rights reserved.
//

#import "UCAPIRequest.h"

/**
 *  Request for local file upload.
 */
@interface UCFileUploadRequest : UCAPIRequest

/**
 *  Creates API request with provided binary data and meta values in order to
 *  perform an upload operation to the Uploadcare service.
 *
 *  @param fileData Binary data of the uploading file.
 *  @param fileName File name.
 *  @param mimeType Contains mime type of provided data. https://developer.apple.com/library/ios/documentation/FileManagement/Conceptual/understanding_utis/understand_utis_conc/understand_utis_conc.html
 *  @see https://uploadcare.com/documentation/upload/#upload-body for more information.
 *  @return UCFileUploadRequest object instance.
 */
+ (instancetype)requestWithFileData:(NSData *)fileData
                           fileName:(NSString *)fileName
                           mimeType:(NSString *)mimeType;

/**
 *  Creates API request with provided local file url in order to
 *  perform an upload operation to the Uploadcare service.
 *
 *  @param fileURL Should be local file url.
 *
 *  @return UCFileUploadRequest object instance.
 */
+ (instancetype)requestWithFileURL:(NSURL *)fileURL;

@end
