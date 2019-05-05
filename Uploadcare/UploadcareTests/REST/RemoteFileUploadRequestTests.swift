//
//  RemoteFileUploadRequestTests.swift
//  UploadcareTests
//
//  Created by Artem Loenko on 05/05/2019.
//  Copyright © 2019 Uploadcare. All rights reserved.
//

import XCTest
@testable import Uploadcare

class RemoteFileUploadRequestTests: XCTestCase {

    func testThatRequestIsValidWhenValidParametersAreProvided() {
        let fileURL = "https://ucarecdn.com/d5049d10-0ba5-4c2f-8ebc-43975d37c933/droppedkitty.jpg"
        let sut = RemoteFileUploadRequest(remoteFileURL: fileURL)

        XCTAssertEqual(sut.path, Configuration.RemoteFile.uploadingPath)
        XCTAssertNil(sut.payload)
        XCTAssertEqual(sut.parameters.count, 0)
        let testQuery = URLQueryItem(
            name: RemoteFileUploadRequest.Constants.sourceURLKey,
            value: fileURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
        XCTAssertEqual(sut.request?.url?.query, testQuery.description)
    }

    func testThatRequestEscapesNonQueryAllowedCharactersWhenFileURLContainsThemBasedOnRFC3986() {
        let fileURLWithNonEspacedCharacters = "https://ucarecdn.com/test#test&test=test.=png"
        let sut = RemoteFileUploadRequest(remoteFileURL: fileURLWithNonEspacedCharacters)

        let escapedURL = sut.request?.url?.query?.split(separator: "=").last
        XCTAssertNotNil(escapedURL)
        XCTAssertFalse(escapedURL!.contains("#"))
        XCTAssertFalse(escapedURL!.contains("$"))
        XCTAssertFalse(escapedURL!.contains("&"))
        XCTAssertFalse(escapedURL!.contains("="))
    }

}
