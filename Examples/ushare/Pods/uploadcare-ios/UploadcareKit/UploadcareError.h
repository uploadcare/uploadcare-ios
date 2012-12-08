//
//  UploadcareError.h
//  UploadcareKit
//
//  Created by Zoreslav Khimich on 10/14/12.
//  Copyright (c) 2012 Uploadcare. All rights reserved.
//

/* Exceptions thrown by the Uploadcare Kit */

/** 
 Uploadcare Kit throws this exception when requested to operate with no public key provided.
 Please consult the documentation: http://github.com/uploadcare/uploadcare-ios */
extern NSString *const UploadcareMissingPublicKeyException;

/** The error domain of errors used by the Uploadcare Kit */
extern NSString *const UploadcareErrorDomain;

/* Error codes used by the SDK */
typedef enum {
    /* Uploadcare back-end failed to process an `upload from URL` request */
    UploadcareErrorUploadingFromURL = 0x1001,
    /* Client application failed to connect to the server */
    UploadcareErrorConnectingHome,
    /* /status/ request on an upload has failed either due to connectivity issues or because of a server-side error */
    UploadcareErrorPollingStatus,
    /* Public key is invalid */
    UploadcareErrorAuthenticatingWithPublicKey,
} UploadcareErrorCode;

NSError *UploadcareMakePubAuthError(NSError *underlyingError);
