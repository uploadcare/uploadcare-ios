//
//  FileInfoRequestTests.swift
//  UploadcareTests
//
//  Created by Artem Loenko on 28/04/2019.
//  Copyright © 2019 Uploadcare. All rights reserved.
//

import XCTest
@testable import Uploadcare

class FileInfoRequestTests: XCTestCase {

    func testThatFileInfoRequestIsValidAfterInitialisation() {
        let id = UUID().uuidString
        let sut = FileInfoRequest(fileID: id)

        XCTAssertEqual(sut.path, Configuration.File.infoPath)
        XCTAssertTrue(sut.parameters.values.filter({ $0 == id }).count == 1)
        XCTAssertTrue(sut.parameters.keys.filter({ $0 == FileInfoRequest.Constants.fileIDKey }).count == 1)
        XCTAssertNil(sut.payload)
    }

}
