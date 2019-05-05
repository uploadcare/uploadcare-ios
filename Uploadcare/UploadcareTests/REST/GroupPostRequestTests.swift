//
//  GroupPostRequestTests.swift
//  UploadcareTests
//
//  Created by Artem Loenko on 05/05/2019.
//  Copyright © 2019 Uploadcare. All rights reserved.
//

import XCTest
@testable import Uploadcare

class GroupPostRequestTests: XCTestCase {

    func testThatRequestIsValidWhenFileIDsAreProvided() {
        let fakePath = "/var/mobile/Containers/Data/Application/Uploadcare"
        let fileIDs = [
            "\(fakePath)/\(UUID().uuidString)",
            "\(fakePath)/\(UUID().uuidString)",
            "\(fakePath)/\(UUID().uuidString)",
            "\(fakePath)/\(UUID().uuidString)",
            "\(fakePath)/\(UUID().uuidString)",
        ]
        let sut = GroupPostRequest(fileIDs: fileIDs)

        XCTAssertEqual(sut.path, Configuration.FileGroup.uploadingPath)
        XCTAssertNil(sut.payload)
        XCTAssertEqual(sut.parameters.count, fileIDs.count)
        fileIDs.forEach { fileID in
            XCTAssertTrue(sut.parameters.values.filter({ $0 == fileID }).count == 1)
        }
    }

}
