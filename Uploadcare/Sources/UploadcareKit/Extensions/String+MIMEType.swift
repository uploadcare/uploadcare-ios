//
//  String+MIMEType.swift
//  Uploadcare
//
//  Created by Artem Loenko on 04/05/2019.
//  Copyright © 2019 Uploadcare. All rights reserved.
//

import MobileCoreServices

extension String {

    var MIMEType: String {
        guard let contentType = UTTypeCopyPreferredTagWithClass(self as CFString, kUTTagClassMIMEType) else {
            return Constants.defaultContentType
        }
        return String(contentType.takeUnretainedValue())
    }

}
