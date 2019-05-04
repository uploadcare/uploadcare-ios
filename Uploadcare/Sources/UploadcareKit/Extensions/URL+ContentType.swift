//
//  URL+UTI.swift
//  Uploadcare
//
//  Created by Artem Loenko on 04/05/2019.
//  Copyright © 2019 Uploadcare. All rights reserved.
//

import MobileCoreServices

extension URL {

    private struct Constants {
        static let defaultContentType = "application/octet-stream"
    }

    var contentType: String {
        guard let UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, self.pathExtension as CFString, nil)?.takeUnretainedValue(), let contentType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType) else {
            return Constants.defaultContentType
        }
        return String(contentType.takeUnretainedValue())
    }

    var UTI: String? {
        guard let typeIdentifier = try? self.resourceValues(forKeys: [ .typeIdentifierKey ]) else { return nil }
        return typeIdentifier.typeIdentifier
    }

}
