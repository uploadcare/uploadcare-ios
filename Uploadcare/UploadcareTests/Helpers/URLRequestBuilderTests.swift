//
//  URLRequestBuilderTests.swift
//  UploadcareTests
//
//  Created by Artem Loenko on 27/05/2019.
//  Copyright © 2019 Uploadcare. All rights reserved.
//

import XCTest
@testable import Uploadcare

class URLRequestBuilderTests: XCTestCase {

    func testThatBuilderProducesCorrectResultsForBaseComponents() {
        let sut = URLRequestBuilder.baseComponents
        XCTAssertEqual(sut.scheme, Configuration.API.scheme)
        XCTAssertEqual(sut.host, Configuration.API.host)
        XCTAssertTrue(sut.path.isEmpty)
        XCTAssertNil(sut.queryItems)
        XCTAssertNotNil(sut.url)
    }

    func testThatBuilderProducesCorrectResultsWhenPathIsSpecifiedForBaseComponents() {
        let path = "/\(UUID().uuidString)"
        let sut = URLRequestBuilder.baseComponents(with: path)
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.path, path)
    }

    func testThatBuilderProducesCorrectResultsWhenPathIsSpecified() {
        let path = "/\(UUID().uuidString)"
        let sut = URLRequestBuilder.build(with: path, queryItems: nil)
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut?.url?.path, path)
    }

    func testThatBuilderProducesCorrectResultsWhenPathAndQueryItemsAreSpecified() {
        let path = "/\(UUID().uuidString)"
        let items = [
            URLQueryItem(name: UUID().uuidString, value: UUID().uuidString),
            URLQueryItem(name: UUID().uuidString, value: UUID().uuidString)
        ]
        let sut = URLRequestBuilder.build(with: path, queryItems: items)
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut?.url?.path, path)
        XCTAssertEqual(
            sut?.url?.query,
            items.description
                .replacingOccurrences(of: ",", with: "&")
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "[", with: "")
                .replacingOccurrences(of: "]", with: ""))
        XCTAssertTrue(sut?.url?.query?.contains(items.first?.name ?? UUID().uuidString) ?? false)
        XCTAssertTrue(sut?.url?.query?.contains(items.first?.value ?? UUID().uuidString) ?? false)
        XCTAssertTrue(sut?.url?.query?.contains(items.last?.name ?? UUID().uuidString) ?? false)
        XCTAssertTrue(sut?.url?.query?.contains(items.last?.value ?? UUID().uuidString) ?? false)
    }

}
