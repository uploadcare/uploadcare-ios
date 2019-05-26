//
//  URLSessionMock.swift
//  UploadcareTests
//
//  Created by Artem Loenko on 26/05/2019.
//  Copyright © 2019 Uploadcare. All rights reserved.
//

import XCTest
@testable import Uploadcare

final class URLSessionMock: URLSessionProtocol {

    var onDataTaskCreation: ((URLRequest, URLSessionMock.CompletionHandler) -> URLSessionDataTaskProtocol)?

    private(set) var request: URLRequest?

    func dataTask(with request: URLRequest, completionHandler: @escaping URLSessionMock.CompletionHandler) -> URLSessionDataTaskProtocol {
        self.request = request
        guard let task = self.onDataTaskCreation?(request, completionHandler) else {
            fatalError("Mock in not configured properly.")
        }
        return task
    }

}
