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
        let queryItems: [ URLQueryItem ] = {
            var items = self.parameters.map { parameter in
                URLQueryItem(name: parameter.key, value: parameter.value)
            }
            items.append(URLQueryItem(name: Constants.sourceURLKey, value: self.fileURL))
            return items
        }()
        let request = URLRequestBuilder.build(with: self.path, queryItems: queryItems)
        return request
    }

}
