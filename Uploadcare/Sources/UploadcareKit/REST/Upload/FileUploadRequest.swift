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

    public var parameters: Dictionary<String, String> = [:]
    public var path: String = Configuration.File.uploadingPath
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
    }

    public init(data: Data, filename: String, mimeType: String) {
        let payload: RequestPayloadProtocol = RequestPayload(
            payload: data,
            name: Constants.defaultName,
            filename: filename,
            mimeType: mimeType)
        self.payload = payload
    }

    public var request: URLRequest? {
        guard let url: URL = {
            var components = URLComponents()
            components.scheme = Configuration.API.scheme
            components.host = Configuration.API.host
            components.path = self.path
            components.queryItems = self.parameters.map { parameter in
                URLQueryItem(name: parameter.key, value: parameter.value)
            }
            guard let url = components.url else { return nil }
            return url
            }() else { return nil }
        return URLRequest(url: url)
    }
}
