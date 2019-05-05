//
//  GroupInfoRequestTests.swift
//  UploadcareTests
//
//  Created by Artem Loenko on 05/05/2019.
//  Copyright © 2019 Uploadcare. All rights reserved.
//

import XCTest
@testable import Uploadcare

class GroupInfoRequestTests: XCTestCase {

    func testThatRequestContainsProperParametersAfterCreation() {
        let groupID = UUID().uuidString
        let sut = GroupInfoRequest(groupID: groupID)

        XCTAssertEqual(sut.path, Configuration.FileGroup.infoPath)
        XCTAssertTrue(sut.parameters.values.filter({ $0 == groupID }).count == 1)
        XCTAssertTrue(sut.parameters.keys.filter({ $0 == GroupInfoRequest.Constants.groupIDKey }).count == 1)
        XCTAssertNil(sut.payload)
    }

}
