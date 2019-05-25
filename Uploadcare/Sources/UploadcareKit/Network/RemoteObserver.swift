//
//  RemoteObserver.swift
//  Uploadcare
//
//  Created by Artem Loenko on 25/05/2019.
//  Copyright © 2019 Uploadcare. All rights reserved.
//

import Foundation

enum RemoteObserverError: Error {
    case noResponseAfterMaximumRetries
    case cannotBuildRequest
    case requestHasFailedWithoutError
    case unableToSerializeJSONWithoutError
    case cannotExtractStatusFromResponse
    case serverError(description: String?)
    case taskIsInProgress
}

final class RemoteObserver {

    typealias JSON = [String: Any]

    struct Constants {
        static let tokenQueryItemKey = "token"
        static let observerRetryCount: Int = 3
        static let observerRequestInterval: Int = 2
    }

    struct PollingStatus {
        struct Keys {
            static let status = "status"
            static let error = "error"
            static let doneBytes = "done"
            static let totalBytes = "total"
        }
        static let success = "success"
        static let progress = "progress"
        static let error = "error"
        static let errorMessageUnknown = "Unknown error"
    }

    let progressBlock: Uploadcare.UploadProgressBlock
    let completionBlock: Uploadcare.CompletionBlock
    let token: String
    var retryCounter: Int = 0
    // FIXME: hide behind protocol all the below
    var timerSource: DispatchSourceTimer?
    let session: URLSession
    var pollingTask: URLSessionDataTask?
    lazy var pollingRequest: URLRequest? = {
        guard let requestURL: URL = {
            var components = URLComponents()
            components.scheme = Configuration.API.scheme
            components.host = Configuration.API.host
            components.path = Configuration.RemoteFile.statusPath
            components.queryItems = [ URLQueryItem(name: Constants.tokenQueryItemKey, value: self.token) ]
            return components.url
            }() else { return nil }
        let request = URLRequest(url: requestURL)
        return request
    }()

    init(token: String, session: URLSession, progress: @escaping Uploadcare.UploadProgressBlock, completion: @escaping Uploadcare.CompletionBlock) {
        self.token = token
        self.session = session
        self.progressBlock = progress
        self.completionBlock = completion
    }

    func startObserving() {
        let timerSource: DispatchSourceTimer = {
            let queue = DispatchQueue.global(qos: .default)
            let source: DispatchSourceTimer = DispatchSource.makeTimerSource(queue: queue)
            source.schedule(deadline: .now(), repeating: .seconds(Constants.observerRequestInterval))
            source.setEventHandler { self.sendPollingRequest() }
            return source
        }()
        self.timerSource = timerSource
    }

    func stopObserving() {
        self.timerSource?.cancel()
        self.timerSource = nil
    }

    // FIXME: throws?
    func sendPollingRequest() {
        // If the task is nil or not running then create one and run it
        guard let pollingTask = self.pollingTask, pollingTask.state == .running else {
            guard let pollingRequest = self.pollingRequest else {
                self.completionBlock(.failure(RemoteObserverError.cannotBuildRequest))
                return
            }
            let task = self.session.dataTask(with: pollingRequest) { [weak self] (data, response, error) in
                let completeWithError = { (error: Error) in
                    self?.stopObserving()
                    // FIXME: add a helper to retrieve an error message from the data
                    self?.completionBlock(.failure(error))
                }
                switch (data, error) {
                case let (_, error?):
                    completeWithError(error)
                case let (data?, _):
                    let jsonObject: JSON? = {
                        do { return try JSONSerialization.jsonObject(with: data, options: []) as? JSON }
                        catch {
                            completeWithError(error)
                            return nil
                        }
                    }()
                    guard let json = jsonObject else {
                        completeWithError(RemoteObserverError.unableToSerializeJSONWithoutError)
                        return
                    }
                    guard let processResult = self?.process(response: json) else {
                        completeWithError(RemoteObserverError.requestHasFailedWithoutError)
                        return
                    }
                    switch processResult {
                    case .failure(let error):
                        switch error {
                        // FIXME: bad design, progress completion is called within .process function
                        case RemoteObserverError.taskIsInProgress:
                            break
                        default:
                            completeWithError(error)
                        }
                    case .success(_):
                        self?.stopObserving()
                        self?.completionBlock(processResult)
                    }
                case (.none, .none):
                    completeWithError(RemoteObserverError.requestHasFailedWithoutError)
                }
            }
            task.resume()
            self.pollingTask = task
            return
        }
        self.retryCounter += 1
        self.stopObserving()
        // If we reached the maximum amount of attempts then stop the task and call the completion
        guard self.retryCounter <= Constants.observerRetryCount else {
            self.completionBlock(.failure(RemoteObserverError.noResponseAfterMaximumRetries))
            return
        }
        // Worst case, task in running but stucked. We cancelled it previously, let's try to create a new one
        self.sendPollingRequest()
    }

    func process(response: JSON) -> Uploadcare.UploadcareResult {
        guard let status = response[PollingStatus.Keys.status] as? String else {
            return .failure(RemoteObserverError.cannotExtractStatusFromResponse)
        }
        switch status {
        case PollingStatus.success:
            return .success(response)
        case PollingStatus.error:
            // FIXME: propogate data to the completion?
            let description = response[PollingStatus.Keys.error] as? String
            return .failure(RemoteObserverError.serverError(description: description))
        case PollingStatus.progress:
            let done = response[PollingStatus.Keys.doneBytes] as? UInt
            let total = response[PollingStatus.Keys.totalBytes] as? UInt
            self.progressBlock(done, total)
            return .failure(RemoteObserverError.taskIsInProgress)
        default:
            return .failure(RemoteObserverError.cannotExtractStatusFromResponse)
        }
    }
}
