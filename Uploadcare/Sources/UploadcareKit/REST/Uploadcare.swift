//
//  Uploadcare.swift
//  Uploadcare
//
//  Created by Artem Loenko on 18/05/2019.
//  Copyright © 2019 Uploadcare. All rights reserved.
//

import Foundation

enum UploadcareError: Error {
    case publicKeyNotFound
}

public class Uploadcare {

    /// Uploadcare service public key for accessing uploading API.
    /// @see https://uploadcare.com/documentation/keys/
    public let publicKey: String

    /// Use this method in order to obtain a session object if you want to use the same delegate flow for your tasks.
    public private(set) var session: URLSession?

    /// NSCache instance which allows user to control cache size and clear it on demand.
    public typealias UploadcareCache = NSCache<NSString, UIImage>
    public let cache: UploadcareCache

    /// A default convenience initializer that will read @publicKey from UserDefaults
    ///
    /// - Throws: UploadcareError.publicKeyNotFound if .publicKey is not found in UserDefaults
    public convenience init() throws {
        guard let publicKey = UserDefaults.standard.string(forKey: Configuration.API.publicKeyIdentifier) else {
            throw UploadcareError.publicKeyNotFound
        }
        self.init(publicKey: publicKey)
    }


    /// A default convenience initializer with a user-defined @publicKey
    ///
    /// - Parameter publicKey: Uploadcare service public key for accessing uploading API
    public convenience init(publicKey: String) {
        self.init(key: publicKey)
    }

    /// A required internal initializer
    ///
    /// - Parameters:
    ///   - key: Uploadcare service public key for accessing uploading API
    ///   - cache: UploadcareCache instance which allows user to control cache size and clear it on demand
    required init(key: String, cache: UploadcareCache = UploadcareCache()) {
        self.publicKey = key
        self.cache = cache
    }
}
