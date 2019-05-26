//
//  URLSessionDataTaskProtocol.swift
//  Uploadcare
//
//  Created by Artem Loenko on 26/05/2019.
//  Copyright © 2019 Uploadcare. All rights reserved.
//

import Foundation

protocol URLSessionDataTaskProtocol {
    var state: URLSessionTask.State { get }
    func resume()
    func suspend()
    func cancel()
}

extension URLSessionDataTask: URLSessionDataTaskProtocol { }
