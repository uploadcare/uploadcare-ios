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

    func testThanObserverHandleNetworkErrorsWhenTaskIsResumed() {
        // Given
        let token = UUID().uuidString
        let fakeNetworkError = RemoteObserver.Errors.serverError(description: nil)
        let session: URLSessionProtocol = {
            let mock = URLSessionMock()
            mock.onDataTaskCreation = { request, completionHandler in
                let task = URLSessionDataTaskMock()
                task.onResume = { completionHandler(nil, nil, fakeNetworkError) }
                return task
            }
            return mock
        }()
        let completionExpectation = expectation(description: "Completion block was called")
        let completion: Uploadcare.CompletionBlock = { result in
            switch result {
            case .failure(let error):
                switch error {
                case RemoteObserver.Errors.serverError(description: nil):
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
        wait(for: [ completionExpectation ], timeout: timeout)

        XCTAssertNil(sut.timerSource)
    }

    func testThanObserverHandleJSONWhenTaskIsFailedDueToServerError() {
        // Given
        let token = UUID().uuidString
        let errorMessage = "error message"
        let json = self.responseForFromURLStatus(with: errorMessage)
        let session: URLSessionProtocol = {
            let mock = URLSessionMock()
            mock.onDataTaskCreation = { request, completionHandler in
                let task = URLSessionDataTaskMock()
                task.onResume = { completionHandler(json, nil, nil) }
                return task
            }
            return mock
        }()
        let completionExpectation = expectation(description: "Completion block was called")
        let completion: Uploadcare.CompletionBlock = { result in
            switch result {
            case .failure(let error):
                switch error {
                case RemoteObserver.Errors.serverError(description: errorMessage):
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
        wait(for: [ completionExpectation ], timeout: timeout)

        XCTAssertNil(sut.timerSource)
    }

    func testThanObserverHandleJSONWhenTaskIsSuccessfullyProcessed() {
        // Given
        let token = UUID().uuidString
        let json = self.responseForFromURLStatusWithSuccess()
        let session: URLSessionProtocol = {
            let mock = URLSessionMock()
            mock.onDataTaskCreation = { request, completionHandler in
                let task = URLSessionDataTaskMock()
                task.onResume = { completionHandler(json, nil, nil) }
                return task
            }
            return mock
        }()
        let completionExpectation = expectation(description: "Completion block was called")
        let completion: Uploadcare.CompletionBlock = { result in
            switch result {
            case .success(_):
                break
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
        wait(for: [ completionExpectation ], timeout: timeout)

        XCTAssertNil(sut.timerSource)
    }

    func testThanObserverHandleJSONWhenTaskIsInProgress() {
        // Given
        let token = UUID().uuidString
        let json = self.responseForFromURLStatusInProgress()
        let session: URLSessionProtocol = {
            let mock = URLSessionMock()
            mock.onDataTaskCreation = { request, completionHandler in
                let task = URLSessionDataTaskMock()
                task.onResume = { completionHandler(json, nil, nil) }
                return task
            }
            return mock
        }()
        let completionExpectation = expectation(description: "Completion block was called")
        let completion: Uploadcare.CompletionBlock = { result in
            completionExpectation.fulfill()
        }
        let progressExpectation = expectation(description: "Progress block was called")
        let progress: Uploadcare.UploadProgressBlock = { bytesSent, bytesLeft in
            XCTAssertNotNil(bytesSent)
            XCTAssertNotNil(bytesLeft)
            progressExpectation.fulfill()
        }
        let sut = RemoteObserver(token: token, session: session, requestRetryInterval: 0.1, progress: progress, completion: completion)

        // When
        sut.startObserving()

        // Then
        let timeout = TimeInterval(sut.requestRetryInterval * Double(RemoteObserver.Constants.observerRetryCount))
        wait(for: [ completionExpectation, progressExpectation ], timeout: timeout)

        XCTAssertNil(sut.timerSource)
    }

}

extension RemoteObserverTests {
    func responseForFromURLStatus(with error: String) -> Data {
        let json = [
            "status": "error",
            "error": error
        ]
        return try! JSONSerialization.data(withJSONObject: json, options: [])
    }

    func responseForFromURLStatusWithSuccess() -> Data {
        let json: [String : Any] = [
            "status": "success",
            "is_stored": true,
            "done": 145212,
            "file_id": "575ed4e8-f4e8-4c14-a58b-1527b6d9ee46",
            "total": 145212,
            "size": 145212,
            "uuid": "575ed4e8-f4e8-4c14-a58b-1527b6d9ee46",
            "is_image": true,
            "filename": "EU_4.jpg",
            "is_ready": true,
            "original_filename": "EU_4.jpg",
            "mime_type": "image/jpeg"
        ]
        return try! JSONSerialization.data(withJSONObject: json, options: [])
    }

    func responseForFromURLStatusInProgress() -> Data {
        let json: [String : Any] = [
            "status": "progress",
            "done": 100,
            "total": 200
        ]
        return try! JSONSerialization.data(withJSONObject: json, options: [])
    }
}
