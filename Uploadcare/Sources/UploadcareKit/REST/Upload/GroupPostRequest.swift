//
//  GroupPostRequest.swift
//  Uploadcare
//
//  Created by Artem Loenko on 05/05/2019.
//  Copyright © 2019 Uploadcare. All rights reserved.
//

import Foundation

/**
 *  Creates group with the provided file uuids.
 *  @see https://uploadcare.com/docs/api_reference/upload/groups/
 */
public final class GroupPostRequest: RequestProtocol {

    public var parameters: Dictionary<String, String>
    public var path: String = Configuration.FileGroup.uploadingPath
    public var payload: RequestPayloadProtocol?

    public init(fileIDs: [ String ]) {
        self.parameters = type(of: self).parameters(from: fileIDs)
    }

    private static func parameters(from fileIDs: [ String ]) -> Dictionary<String, String> {
        var parameters = Dictionary<String, String>()
        for (index, element) in fileIDs.enumerated() {
            let key = "files[\(index)]"
            parameters[key] = element
        }
        return parameters
    }
}
