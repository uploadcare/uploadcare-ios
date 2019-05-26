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
        let session = URLSessionMock()
        let sut = RemoteObserver(token: token, session: session)

        XCTAssertEqual(sut.token, token)
        XCTAssertEqual(sut.retryCounter, 0)
        XCTAssertNil(sut.completionBlock)
        XCTAssertNil(sut.progressBlock)
        XCTAssertNil(sut.pollingTask)
        XCTAssertNil(sut.timerSource)
    }

    func testThanObserverCallsCompletionHandlerWithProperErrorWhenServerDoesNotRespond() {
        // Given
        let token = UUID().uuidString
        let onResumeExpectation = expectation(description: ".resume was called on the task")
        let task: URLSessionDataTaskProtocol = {
            let mock = URLSessionDataTaskMock()
            mock.onResume = { onResumeExpectation.fulfill() }
            return mock
        }()
        let session: URLSessionProtocol = {
            let mock = URLSessionMock()
            mock.onDataTaskCreation = { request, completionHandler in return task }
            return mock
        }()
        let completionExpectation = expectation(description: "Completion block was called")
        let completion: Uploadcare.CompletionBlock = { result in
            switch result {
            case .failure(let error):
                switch error {
                case RemoteObserver.Errors.noResponseAfterMaximumRetries:
                    break
                default:
                    XCTFail("Failue should be with an expected error type")
                }
            default:
                XCTFail("Should not reach this case")
            }
            completionExpectation.fulfill()
        }
        let sut = RemoteObserver(token: token, session: session, requestRetryInterval: 0.1, completion: completion)

        // When
        sut.startObserving()

        // Then
        let timeout = TimeInterval(sut.requestRetryInterval * Double(RemoteObserver.Constants.observerRetryCount))
        wait(for: [ onResumeExpectation, completionExpectation ], timeout: timeout)
    }

    func testThanObserverRetriesRequestWithProperCounterWhenServerDoesNotRespond() {
        // Given
        let token = UUID().uuidString
        let session: URLSessionProtocol = {
            let mock = URLSessionMock()
            mock.onDataTaskCreation = { request, completionHandler in return URLSessionDataTaskMock() }
            return mock
        }()
        let completionExpectation = expectation(description: "Completion block was called")
        let completion: Uploadcare.CompletionBlock = { result in
            completionExpectation.fulfill()
        }
        let sut = RemoteObserver(token: token, session: session, requestRetryInterval: 0.1, completion: completion)

        // When
        sut.startObserving()

        // Then
        let timeout = TimeInterval(sut.requestRetryInterval * Double(RemoteObserver.Constants.observerRetryCount))
        wait(for: [ completionExpectation ], timeout: timeout)

        XCTAssertEqual(sut.retryCounter, RemoteObserver.Constants.observerRetryCount)
    }

    func testThanObserverDeallocatesTaskWhenServerDoesNotRespond() {
        // Given
        let token = UUID().uuidString
        let session: URLSessionProtocol = {
            let mock = URLSessionMock()
            mock.onDataTaskCreation = { request, completionHandler in return URLSessionDataTaskMock() }
            return mock
        }()
        let completionExpectation = expectation(description: "Completion block was called")
        let completion: Uploadcare.CompletionBlock = { result in
            completionExpectation.fulfill()
        }
        let sut = RemoteObserver(token: token, session: session, requestRetryInterval: 0.1, completion: completion)

        // When
        sut.startObserving()

        // Then
        let timeout = TimeInterval(sut.requestRetryInterval * Double(RemoteObserver.Constants.observerRetryCount))
        wait(for: [ completionExpectation ], timeout: timeout)

        XCTAssertNil(sut.pollingTask)
    }

}
