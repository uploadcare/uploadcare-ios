//
//  UploadcareTests.swift
//  UploadcareTests
//
//  Created by Artem Loenko on 18/05/2019.
//  Copyright © 2019 Uploadcare. All rights reserved.
//

import XCTest
@testable import Uploadcare

class UploadcareTests: XCTestCase {

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: Configuration.API.publicKeyIdentifier)
    }

    func testThatInitialzerIsThrowingWhenThereIsNoKeyInUserDefaults() {
        XCTAssertThrowsError(try Uploadcare())
    }

    func testThatInitialzerIsNotThrowingWhenThereIsKeyInUserDefaults() {
        UserDefaults.standard.set(UUID().uuidString, forKey: Configuration.API.publicKeyIdentifier)
        XCTAssertNoThrow(try Uploadcare())
    }

    func testThatUploadcareInstanceContainsProperValuesWhenSetUpIsSuccessful() {
        let publicKey = UUID().uuidString
        UserDefaults.standard.set(publicKey, forKey: Configuration.API.publicKeyIdentifier)
        let sut: Uploadcare? = {
            do { return try Uploadcare() }
            catch { XCTFail("Initializer should not fail.") }
            return nil
        }()
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut?.publicKey, publicKey)
        XCTAssertNotNil(sut?.cache)
    }

}
