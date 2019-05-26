//
//  URLSessionDataTaskMock.swift
//  UploadcareTests
//
//  Created by Artem Loenko on 26/05/2019.
//  Copyright © 2019 Uploadcare. All rights reserved.
//

import XCTest
@testable import Uploadcare

final class URLSessionDataTaskMock {

    var onResume: (() -> Void)?
    var onSuspend: (() -> Void)?
    var onCancel: (() -> Void)?

    var state: URLSessionTask.State = .suspended

    func resume() {
        self.state = .running
        self.onResume?()
    }

    func suspend() {
        self.state = .suspended
        self.onSuspend?()
    }

    func cancel() {
        self.state = .canceling
        self.onCancel?()
    }

}

extension URLSessionDataTaskMock: URLSessionDataTaskProtocol { }
