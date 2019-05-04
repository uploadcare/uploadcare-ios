//
//  FileUploadRequestTests.swift
//  UploadcareTests
//
//  Created by Artem Loenko on 04/05/2019.
//  Copyright © 2019 Uploadcare. All rights reserved.
//

import XCTest
@testable import Uploadcare

class FileUploadRequestTests: XCTestCase {

    func testThatRequestIsCorrectWhenValidDataIsProvided() {
        let pathExtension = "png"
        let fakeURL = URL(string: "/var/temp/image.\(pathExtension)")!
        let data = "test_data".data(using: .utf8)!
        let sut = FileUploadRequest(data: data, filename: fakeURL.lastPathComponent, mimeType: fakeURL.pathExtension.MIMEType)

        XCTAssertEqual(sut.path, Configuration.File.uploadingPath)
        XCTAssertEqual(sut.payload?.mimeType, pathExtension.MIMEType)
        XCTAssertEqual(sut.payload?.filename, fakeURL.lastPathComponent)
        XCTAssertEqual(sut.payload?.payload, data)
    }

    func testThatInitializerWillFailWhenFileURLPointsToDirectory() {
        let fakeURL = URL(string: "/var/temp/")!
        let sut = FileUploadRequest(fileURL: fakeURL)
        XCTAssertNil(sut)
    }

    func testThatInitializerWillFailWhenFileURLPointsToNonExistedFile() {
        let fakeURL = URL(string: "/var/temp/none.png")!
        let sut = FileUploadRequest(fileURL: fakeURL)
        XCTAssertNil(sut)
    }

}
