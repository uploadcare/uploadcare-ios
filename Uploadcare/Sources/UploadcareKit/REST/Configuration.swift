//
//  Configuration.swift
//  Uploadcare
//
//  Created by Artem Loenko on 27/04/2019.
//  Copyright © 2019 Uploadcare. All rights reserved.
//

import Foundation

public struct Configuration {
    struct API {
        static let scheme = "https"
        static let host = "upload.uploadcare.com"
    }
    struct File {
        static let uploadingPath = "/base/"
        static let infoPath = "/info/"
    }
    struct RemoteFile {
        static let uploadingPath = "/from_url/"
        static let statusPath = "/from_url/status/"
    }
    struct FileGroup {
        static let uploadingPath = "/group/"
        static let infoPath = "/group/info"
    }
    struct Domain {
        static let root = "com.uploadcare.upload"
        static let localFileUpload = "local"
        static let remoteFileUpload = "remote"
    }
    struct Error {
        static let unknown = 1001
        static let uploadcare = 1002
    }
}
