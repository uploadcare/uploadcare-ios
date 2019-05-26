//
//  MultipartFormData.swift
//  UploadcareTests
//
//  Created by Artem Loenko on 19/05/2019.
//  Copyright © 2019 Uploadcare. All rights reserved.
//

import Foundation

enum MultipartFormDataError: Error {
    case cannotCreateData
}

protocol MultipartFormDataProtocol {
    var boundary: String { get }
    var multipartData: Data { get }
    var contentLength: Int { get }
    var bodyByFinalizingMultipartData: Data { get }

    func append(data: Data, name: String, fileName: String, mimeType: String) throws
    func append(value: String, name: String) throws
    func append(payload: RequestPayloadProtocol) throws
}

final class MultipartFormData: MultipartFormDataProtocol {

    var multipartData: Data
    var boundary: String

    var contentLength: Int {
        return self.bodyByFinalizingMultipartData.count
    }

    var bodyByFinalizingMultipartData: Data {
        var data = self.multipartData
        guard let boundaryData = type(of: self).multipartFormFinalBoundary(with: self.boundary).data(using: .utf8) else {
            // FIXME: switch to throw or to optional value?
            fatalError("Cannot convert the boundary to the UTF8 data.")
        }
        data.append(boundaryData)
        return data
    }

    init() {
        self.multipartData = Data()
        self.boundary = type(of: self).multipartFormBoundary
    }

    func append(data: Data, name: String, fileName: String, mimeType: String) throws {
        let CRLF = type(of: self).multipartFormCRLF
        guard
            let boundaryData = type(of: self).multipartFormInitialBoundary(with: self.boundary).data(using: .utf8),
            let contentDispositionData = "Content-Disposition: form-data; name=\\\(name)\\; filename=\\\(fileName)\\\(CRLF)".data(using: .utf8),
            let contentTypeData = "Content-Type: \(mimeType)\(CRLF)\(CRLF)".data(using: .utf8),
            let CRLFData = CRLF.data(using: .utf8)
        else {
            throw MultipartFormDataError.cannotCreateData
        }
        self.multipartData.append(boundaryData)
        self.multipartData.append(contentDispositionData)
        self.multipartData.append(contentTypeData)
        self.multipartData.append(data)
        self.multipartData.append(CRLFData)
    }

    func append(value: String, name: String) throws {
        let CRLF = type(of: self).multipartFormCRLF
        guard
            let boundaryData = type(of: self).multipartFormInitialBoundary(with: self.boundary).data(using: .utf8),
            let contentDispositionData = "Content-Disposition: form-data; name=\\\(name)\\\(CRLF)\(CRLF)".data(using: .utf8),
            let valueData = "\(value)\(CRLF)".data(using: .utf8)
            else {
                throw MultipartFormDataError.cannotCreateData
        }
        self.multipartData.append(boundaryData)
        self.multipartData.append(contentDispositionData)
        self.multipartData.append(valueData)
    }

    func append(payload: RequestPayloadProtocol) throws {
        try self.append(data: payload.payload, name: payload.name, fileName: payload.filename, mimeType: payload.mimeType)
    }

}

extension MultipartFormData {
    @inline(__always)
    static let multipartFormCRLF = "\r\n"

    @inline(__always)
    static let multipartFormBoundary: String = {
        return String(format: "boundary+%08X%08X", arc4random(), arc4random())
    }()

    @inline(__always)
    static func multipartFormInitialBoundary(with boundary: String) -> String {
        return "--\(boundary)\(MultipartFormData.multipartFormCRLF)"
    }

    @inline(__always)
    static func multipartFormFinalBoundary(with boundary: String) -> String {
        return "\(MultipartFormData.multipartFormCRLF)--\(boundary)--\(MultipartFormData.multipartFormCRLF)"
    }
}
