//
//  FileUploadRequest.swift
//  Uploadcare
//
//  Created by Artem Loenko on 28/04/2019.
//  Copyright © 2019 Uploadcare. All rights reserved.
//

import Foundation

public final class FileUploadRequest: RequestProtocol {

    private struct Constants {
        static let defaultName = "file"
    }

    public var parameters: Dictionary<String, String>
    public var path: String
    public var payload: RequestPayloadProtocol?

    public init?(fileURL: URL) {
        guard fileURL.isFileURL, let data = FileManager.default.contents(atPath: fileURL.path) else {
            return nil
        }
        let payload: RequestPayloadProtocol = RequestPayload(
            payload: data,
            name: Constants.defaultName,
            filename: fileURL.lastPathComponent,
            mimeType: fileURL.contentType)
        self.payload = payload
        self.path = Configuration.File.uploadingPath
        self.parameters = [:]
    }

}
