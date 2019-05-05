//
//  RemoteFileUploadRequest.swift
//  Uploadcare
//
//  Created by Artem Loenko on 05/05/2019.
//  Copyright © 2019 Uploadcare. All rights reserved.
//

import Foundation

public final class RemoteFileUploadRequest: RequestProtocol {

    struct Constants {
        static let sourceURLKey = "source_url"
    }

    public var parameters: Dictionary<String, String> = [:]
    public var path: String = Configuration.RemoteFile.uploadingPath
    public var payload: RequestPayloadProtocol?
    public private(set) var fileURL: String

    public init(remoteFileURL: String) {
        self.fileURL = remoteFileURL
    }

    public var request: URLRequest? {
        guard let url: URL = {
            // This structure parses and constructs URLs according to RFC 3986.
            var components = URLComponents()
            components.scheme = Configuration.API.scheme
            components.host = Configuration.API.host
            components.path = self.path
            components.queryItems = self.parameters.map { parameter in
                URLQueryItem(name: parameter.key, value: parameter.value)
            }
            let sourceURLQueryItem = URLQueryItem(name: Constants.sourceURLKey, value: self.fileURL)
            components.queryItems?.append(sourceURLQueryItem)
            return components.url
            }() else { return nil }
        return URLRequest(url: url)
    }

}
