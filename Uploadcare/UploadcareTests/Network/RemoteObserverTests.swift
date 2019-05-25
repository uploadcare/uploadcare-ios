//
//  RemoteObserverTests.swift
//  UploadcareTests
//
//  Created by Artem Loenko on 25/05/2019.
//  Copyright © 2019 Uploadcare. All rights reserved.
//

import XCTest
@testable import Uploadcare

class RemoteObserverTests: XCTestCase {

    func testThatObserverCanBeCreatedProperly() {
        let token = UUID().uuidString
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        let sut = RemoteObserver(token: token, session: session)

        XCTAssertEqual(sut.token, token)
        XCTAssertEqual(sut.session, session)
        XCTAssertEqual(sut.retryCounter, 0)
        XCTAssertNil(sut.completionBlock)
        XCTAssertNil(sut.progressBlock)
        XCTAssertNil(sut.pollingTask)
        XCTAssertNil(sut.timerSource)
    }

    func testThanObserverCallsCompletionHandlerWhenScenarioIsSuccessful() {
        let token = UUID().uuidString
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        let completion: Uploadcare.CompletionBlock = { result in
            print(result)
        }
        let sut = RemoteObserver(token: token, session: session, completion: completion)
        sut.startObserving()
    }

}
