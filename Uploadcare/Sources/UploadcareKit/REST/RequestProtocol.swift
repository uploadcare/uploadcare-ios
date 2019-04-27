//
//  RequestProtocol.swift
//  Uploadcare
//
//  Created by Artem Loenko on 27/04/2019.
//  Copyright © 2019 Uploadcare. All rights reserved.
//

import Foundation

/**
 *  Base API request class which contains all necessary data for NSURLSession.
 */
public protocol RequestProtocol {
    var parameters: Dictionary<String, String> { get set }
    var path: String { get set }
    var payload: RequestPayloadProtocol { get set }
    var request: URLRequest? { get }
}

public extension RequestProtocol {
    var request: URLRequest? {
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
