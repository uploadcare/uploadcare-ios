//
//  FileInfoRequest.swift
//  Uploadcare
//
//  Created by Artem Loenko on 28/04/2019.
//  Copyright © 2019 Uploadcare. All rights reserved.
//

import Foundation

/**
 *  Requests file information from Uploadcare service.
 */
public final class FileInfoRequest: RequestProtocol {

    struct Constants {
        static let fileIDKey: String = "file_id"
    }

    public let parameters: Dictionary<String, String>
    public let path: String
    public let payload: RequestPayloadProtocol? = nil

    public init(fileID: String) {
        self.parameters = [ Constants.fileIDKey : fileID ]
        self.path = Configuration.File.infoPath
    }
}
