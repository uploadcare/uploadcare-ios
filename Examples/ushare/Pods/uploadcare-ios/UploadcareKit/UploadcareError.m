//
//  UploadcareError.m
//  UploadcareKit
//
//  Created by Zoreslav Khimich on 10/14/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

#import "UploadcareError.h"

NSString *const UploadcareMissingPublicKeyException = @"UploadcareMissingPublicKeyException";

NSString *const UploadcareErrorDomain = @"com.uploadcare.sdk.ErrorDomain";

NSError *UploadcareMakePubAuthError(NSError *underlyingError) {
    /* NOTE: Some application will present localizedDescription & localizedFailureReason straight to the end user,
             so it's better not to provide too much details there */
    NSError *result = [NSError errorWithDomain:UploadcareErrorDomain code:UploadcareErrorAuthenticatingWithPublicKey userInfo:@{
             NSLocalizedFailureReasonErrorKey : @"Uploadcare public key is not valid.",
                         NSUnderlyingErrorKey : underlyingError,
                       }];
    return result;
}