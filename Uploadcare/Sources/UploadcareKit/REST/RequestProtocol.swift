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
    var parameters: Dictionary<String, String> { get }
    var path: String { get }
    var payload: RequestPayloadProtocol? { get }
    var request: URLRequest? { get }
}

public extension RequestProtocol {
    var request: URLRequest? {
        let request = URLRequestBuilder.build(
            with: self.path,
            queryItems: self.parameters.map { parameter in
                URLQueryItem(name: parameter.key, value: parameter.value)
        })
        return request
    }
}
