//
//  ContentTypeTests.swift
//  UploadcareTests
//
//  Created by Artem Loenko on 04/05/2019.
//  Copyright © 2019 Uploadcare. All rights reserved.
//

import XCTest
@testable import Uploadcare

class ContentTypeTests: XCTestCase {

    func testThatContentTypeIsCorrectWhenValidExtensionsAreProvided() {
        XCTAssertEqual("image/png", self.url(with: "png").contentType)
        XCTAssertEqual("image/jpeg", self.url(with: "jpeg").contentType)
        XCTAssertEqual("image/jpeg", self.url(with: "jpg").contentType)
        XCTAssertEqual("video/mp4", self.url(with: "mp4").contentType)
        XCTAssertEqual("audio/mpeg", self.url(with: "mp3").contentType)
        XCTAssertEqual("audio/x-m4a", self.url(with: "m4a").contentType)
    }

    func testThatContentTypeReturnsDefaultValueWhenExtensionIsUnknownOrIncorrect() {
        XCTAssertEqual("application/octet-stream", self.url(with: "incorrectExtension").contentType)
        XCTAssertEqual("application/octet-stream", self.url(with: "pngpng").contentType)
        XCTAssertEqual("application/octet-stream", self.url(with: "...").contentType)
    }

    private func url(with pathExtension: String) -> URL {
        let base = URL(string: "/var/temp")
        let url = URL(fileURLWithPath: "testFile.\(pathExtension)", relativeTo: base)
        return url
    }

}
