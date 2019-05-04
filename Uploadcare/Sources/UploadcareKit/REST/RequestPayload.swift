//
//  RequestPayload.swift
//  Uploadcare
//
//  Created by Artem Loenko on 28/04/2019.
//  Copyright © 2019 Uploadcare. All rights reserved.
//

import Foundation

public final class RequestPayload: RequestPayloadProtocol {
    public let payload: Data
    public let name: String
    public let filename: String
    public let mimeType: String
    
    public init(payload: Data, name: String, filename: String, mimeType: String) {
        self.payload = payload
        self.name = name
        self.filename = filename
        self.mimeType = mimeType
    }
}
