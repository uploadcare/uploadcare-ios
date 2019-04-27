//
//  UploadcareTests.swift
//  UploadcareTests
//
//  Created by Artem Loenko on 27/04/2019.
//  Copyright © 2019 Uploadcare. All rights reserved.
//

import XCTest
@testable import Uploadcare

class UploadcareTests: XCTestCase {

    func testThatRequestIsValidWhenConstructedWithExpectedValues() {
        let path = "/some/path/components"
        let parameters = [ UUID().uuidString : UUID().uuidString ]
        guard let sut = Request(parameters: parameters, path: path).request else {
            XCTAssert(false, "Cannot construct Request with valid values")
            return
        }
        XCTAssertEqual(sut.url?.scheme, Configuration.API.scheme)
        XCTAssertEqual(sut.url?.host, Configuration.API.host)
        XCTAssertEqual(sut.url?.path, path)
        let parametersQuery: String? = {
            var components = URLComponents()
            components.queryItems = parameters.map { parameter in
                URLQueryItem(name: parameter.key, value: parameter.value)
            }
            return components.query
        }()
        XCTAssertEqual(sut.url?.query, parametersQuery)
    }

    func testThatRequestGetterWillFailWhenPathIsInvalid() {
        let sut = Request(path: "invalid|path").request
        XCTAssertNil(sut)
    }
}

private final class Request: RequestProtocol {
    var parameters: Dictionary<String, String>
    var path: String
    var payload: RequestPayloadProtocol

    init(parameters: Dictionary<String, String> = [ "Key" : "Value" ],
         path: String = "/path",
         payload: RequestPayloadProtocol = RequestPayload()) {
        self.parameters = parameters
        self.path = path
        self.payload = payload
    }
}

private final class RequestPayload: RequestPayloadProtocol {
    var payload: Data
    var name: String
    var filename: String
    var mimeType: String

    init(payload: Data = Data(), name: String = "name", filename: String = "filename", mimeType: String = "mimeType") {
        self.payload = payload
        self.name = name
        self.filename = filename
        self.mimeType = mimeType
    }
}
