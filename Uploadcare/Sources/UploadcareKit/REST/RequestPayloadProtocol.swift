//
//  RequestPayloadProtocol.swift
//  Uploadcare
//
//  Created by Artem Loenko on 27/04/2019.
//  Copyright © 2019 Uploadcare. All rights reserved.
//

import Foundation

/**
 *  UCAPIRequestPayload is used for multipart/form-data requests and contains
 *  all necessary values for it's construction.
 */
@objc
public protocol RequestPayloadProtocol {
    var payload: Data { get set }
    var name: String { get set }
    var filename: String { get set }
    var mimeType: String { get set }
}
