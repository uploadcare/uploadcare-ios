//
//  URLSessionProtocol.swift
//  Uploadcare
//
//  Created by Artem Loenko on 26/05/2019.
//  Copyright © 2019 Uploadcare. All rights reserved.
//

import Foundation

protocol URLSessionProtocol {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void

    func dataTask(with request: URLRequest, completionHandler: @escaping CompletionHandler) -> URLSessionDataTaskProtocol
}

extension URLSession: URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping URLSession.CompletionHandler) -> URLSessionDataTaskProtocol {
        return (self.dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask) as URLSessionDataTaskProtocol
    }
}
