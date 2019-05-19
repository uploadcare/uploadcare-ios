//
//  MultipartFormDataTests.swift
//  UploadcareTests
//
//  Created by Artem Loenko on 19/05/2019.
//  Copyright © 2019 Uploadcare. All rights reserved.
//

import XCTest
@testable import Uploadcare

class MultipartFormDataTests: XCTestCase {

    func testThatObjectIsSetUpCorrectlyAfterInstantiation() {
        let sut = MultipartFormData()

        XCTAssertNotNil(sut.multipartData)
        XCTAssertNotNil(sut.boundary)
        XCTAssertEqual(sut.bodyByFinalizingMultipartData, MultipartFormData.multipartFormFinalBoundary(with: sut.boundary).data(using: .utf8))
        XCTAssertEqual(sut.contentLength, MultipartFormData.multipartFormFinalBoundary(with: sut.boundary).data(using: .utf8)?.count)
    }

    func testThatAppendDataProducesCorrectResultsWhenNewDataIsAppended() {
        // Given
        let sut = MultipartFormData()
        let initialBodyByFinalizingMultipartData = sut.bodyByFinalizingMultipartData

        // When
        let dataString = UUID().uuidString
        let data = dataString.data(using: .utf8)!
        let name = UUID().uuidString
        let fileName = UUID().uuidString
        let mimeType = UUID().uuidString
        XCTAssertNoThrow(try sut.append(data: data, name: name, fileName: fileName, mimeType: mimeType))

        // Then
        XCTAssertGreaterThan(sut.bodyByFinalizingMultipartData.count, initialBodyByFinalizingMultipartData.count)
        [ dataString, name, fileName, mimeType ].forEach {
            XCTAssertTrue(String(data: sut.bodyByFinalizingMultipartData, encoding: .utf8)?.contains($0) ?? false)
            XCTAssertNotNil(sut.bodyByFinalizingMultipartData.range(of: $0.data(using: .utf8)!))
        }
        let CRLF = MultipartFormData.multipartFormCRLF.data(using: .utf8)!
        XCTAssertNotNil(sut.bodyByFinalizingMultipartData.range(of: CRLF))
    }

    func testThatAppendValueProducesCorrectResultsWhenNewValueIsAppended() {
        // Given
        let sut = MultipartFormData()
        let initialBodyByFinalizingMultipartData = sut.bodyByFinalizingMultipartData

        // When
        let value = UUID().uuidString
        let name = UUID().uuidString
        XCTAssertNoThrow(try sut.append(value: value, name: name))

        // Then
        XCTAssertGreaterThan(sut.bodyByFinalizingMultipartData.count, initialBodyByFinalizingMultipartData.count)
        [ value, name ].forEach {
            XCTAssertTrue(String(data: sut.bodyByFinalizingMultipartData, encoding: .utf8)?.contains($0) ?? false)
            XCTAssertNotNil(sut.bodyByFinalizingMultipartData.range(of: $0.data(using: .utf8)!))
        }
        let CRLF = MultipartFormData.multipartFormCRLF.data(using: .utf8)!
        XCTAssertNotNil(sut.bodyByFinalizingMultipartData.range(of: CRLF))
    }

    func testThatAppendPayloadProducesCorrectResultsWhenNewPayloadIsAppended() {
        // Given
        let sut = MultipartFormData()
        let initialBodyByFinalizingMultipartData = sut.bodyByFinalizingMultipartData

        // When
        let dataString = UUID().uuidString
        let data = dataString.data(using: .utf8)!
        let name = UUID().uuidString
        let fileName = UUID().uuidString
        let mimeType = UUID().uuidString
        let payload = RequestPayload(payload: data, name: name, filename: fileName, mimeType: mimeType)
        XCTAssertNoThrow(try sut.append(payload: payload))

        // Then
        XCTAssertGreaterThan(sut.bodyByFinalizingMultipartData.count, initialBodyByFinalizingMultipartData.count)
        [ String(data: payload.payload, encoding: .utf8)!, payload.name, payload.filename, payload.mimeType ].forEach {
            XCTAssertTrue(String(data: sut.bodyByFinalizingMultipartData, encoding: .utf8)?.contains($0) ?? false)
            XCTAssertNotNil(sut.bodyByFinalizingMultipartData.range(of: $0.data(using: .utf8)!))
        }
        let CRLF = MultipartFormData.multipartFormCRLF.data(using: .utf8)!
        XCTAssertNotNil(sut.bodyByFinalizingMultipartData.range(of: CRLF))
    }

}
