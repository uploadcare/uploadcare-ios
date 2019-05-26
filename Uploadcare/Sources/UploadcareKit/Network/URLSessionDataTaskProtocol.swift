//
//  URLSessionDataTaskProtocol.swift
//  Uploadcare
//
//  Created by Artem Loenko on 26/05/2019.
//  Copyright © 2019 Uploadcare. All rights reserved.
//

protocol URLSessionDataTaskProtocol {
    var state: URLSessionTask.State { get }
    func resume()
}

extension URLSessionDataTask: URLSessionDataTaskProtocol { }
